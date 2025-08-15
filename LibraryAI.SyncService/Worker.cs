using System;
using System.Collections.Generic;
using System.Data;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json.Serialization;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using MySql.Data.MySqlClient;
using Npgsql;

namespace LibraryAI.SyncService;

public class Worker(ILogger<Worker> _logger) : BackgroundService
{
    private readonly string _mysqlConnStr = Environment.GetEnvironmentVariable("MYSQL_CONNECTION") ?? throw new Exception("MYSQL_CONNECTION env var not set");
    private readonly string _pgConnStr = Environment.GetEnvironmentVariable("POSTGRES_CONNECTION") ?? throw new Exception("POSTGRES_CONNECTION env var not set");
    private readonly string _ollamaHost = Environment.GetEnvironmentVariable("OLLAMA_HOST") ?? "ollama";
    private readonly string _ollamaPort = Environment.GetEnvironmentVariable("OLLAMA_PORT") ?? "11434";

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting sync service...");
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var mysqlConn = new MySqlConnection(_mysqlConnStr);
                await mysqlConn.OpenAsync(stoppingToken);
                using var pgConn = new NpgsqlConnection(_pgConnStr);
                await pgConn.OpenAsync(stoppingToken);

                var books = await FetchBooksAsync(mysqlConn, stoppingToken);
                _logger.LogInformation($"Fetched {books.Count} books from MySQL");

                foreach (var book in books)
                {
                    var embedding = await GetEmbeddingAsync(book, stoppingToken);
                    if (embedding == null)
                    {
                        _logger.LogWarning($"Failed to get embedding for book ID {book.Id}");
                        continue;
                    }
                    await InsertBookAsync(pgConn, book, embedding, stoppingToken);
                    _logger.LogInformation($"Inserted book ID {book.Id} into PostgreSQL");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in sync service");
            }

            // Wait for 3 hour or until cancellation is requested
            _logger.LogInformation("Waiting for the next cycle of updates...");
            await Task.Delay(TimeSpan.FromHours(3), stoppingToken);
        }
    }

    private async Task<List<BookRecord>> FetchBooksAsync(MySqlConnection conn, CancellationToken ct)
    {
        var books = new List<BookRecord>();
        var cmd = new MySqlCommand(@"SELECT b.id, b.title, b.author, b.brief_summary, g.name as genre FROM tbl_books b LEFT JOIN tbl_genres g ON b.genre = g.id", conn);
        using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            books.Add(new BookRecord
            {
                Id = reader.GetInt32("id"),
                Title = reader.GetString("title"),
                Author = reader.GetString("author"),
                Summary = reader.IsDBNull("brief_summary") ? string.Empty : reader.GetString("brief_summary"),
                Genre = reader.IsDBNull("genre") ? null : reader.GetString("genre")
            });
        }
        return books;
    }

    private async Task<float[]?> GetEmbeddingAsync(BookRecord book, CancellationToken ct)
    {
        using var http = new HttpClient { BaseAddress = new Uri($"http://{_ollamaHost}:{_ollamaPort}") };
        var prompt = $"{book.Title} {book.Author} {book.Summary}";
        var req = new { model = "nomic-embed-text", prompt };
        try
        {
            var resp = await http.PostAsJsonAsync("/api/embeddings", req, ct);
            resp.EnsureSuccessStatusCode();
            var result = await resp.Content.ReadFromJsonAsync<OllamaEmbeddingResponse>(cancellationToken: ct);
            return result?.Embedding;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, $"Embedding failed for book: {book.Title}");
            return null;
        }
    }

    private async Task InsertBookAsync(NpgsqlConnection conn, BookRecord book, float[] embedding, CancellationToken ct)
    {
        // Insert or upsert into tbl_books in Postgres
        var cmd = new NpgsqlCommand(@"
            INSERT INTO tbl_books (book_id, title, author, genre, summary, embedding, created_at, updated_at)
            VALUES (@book_id, @title, @author, @genre, @summary, @embedding, NOW(), NOW())
            ON CONFLICT (book_id) DO UPDATE SET
                title = EXCLUDED.title,
                author = EXCLUDED.author,
                genre = EXCLUDED.genre,
                summary = EXCLUDED.summary,
                embedding = EXCLUDED.embedding,
                updated_at = NOW();
        ", conn);
        cmd.Parameters.AddWithValue("book_id", book.Id);
        cmd.Parameters.AddWithValue("title", book.Title);
        cmd.Parameters.AddWithValue("author", book.Author);
        cmd.Parameters.AddWithValue("genre", (object?)book.Genre ?? DBNull.Value);
        cmd.Parameters.AddWithValue("summary", book.Summary);
        cmd.Parameters.AddWithValue("embedding", embedding);
        await cmd.ExecuteNonQueryAsync(ct);
    }

    private class BookRecord
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Author { get; set; } = string.Empty;
        public string Summary { get; set; } = string.Empty;
        public string? Genre { get; set; }
    }

    private class OllamaEmbeddingResponse
    {
        [JsonPropertyName("embedding")]
        public float[] Embedding { get; set; } = Array.Empty<float>();
    }
}
