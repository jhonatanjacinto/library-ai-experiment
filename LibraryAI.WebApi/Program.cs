using System.Text.Json.Serialization;
using System.Text.Json;
using Npgsql;
using Pgvector;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "LibraryAI WebApi!");

app.MapPost("/search", async (HttpContext httpContext, IConfiguration config, ILogger<Program> logger) =>
{
	var request = await JsonSerializer.DeserializeAsync<SearchRequest>(httpContext.Request.Body, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
	if (request == null || string.IsNullOrWhiteSpace(request.Query))
		return Results.BadRequest(new { error = "Missing or invalid query" });

	// Get OLLAMA host/port from env or config
	var ollamaHost = config["OLLAMA_HOST"] ?? "ollama";
	var ollamaPort = config["OLLAMA_PORT"] ?? "11434";
	var ollamaUrl = $"http://{ollamaHost}:{ollamaPort}/api/embeddings";

	// Get embedding for the query
	var ollamaReq = new { model = "nomic-embed-text", prompt = request.Query };
	float[] embedding;
	using (var http = new HttpClient())
	{
		var resp = await http.PostAsJsonAsync(ollamaUrl, ollamaReq);
		if (!resp.IsSuccessStatusCode)
			return Results.Problem($"Failed to get embedding from OLLAMA: {resp.StatusCode}");
		var ollamaResp = await resp.Content.ReadFromJsonAsync<OllamaEmbeddingResponse>();
		embedding = ollamaResp?.Embedding ?? throw new Exception("No embedding returned");
	}

	// Connect to Postgres and run vector search
	var pgConnStr = config["POSTGRES_CONNECTION"] ?? "Host=postgres;Database=libraryai_vector_db;Username=postgres;Password=postgres_pass";
	var results = new List<BookRecommendation>();
	var dataSourceBuilder = new NpgsqlDataSourceBuilder(pgConnStr);
	dataSourceBuilder.UseVector();
	var dataSource = dataSourceBuilder.Build();
	await using (var conn = dataSource.CreateConnection())
	{
		await conn.OpenAsync();
		var cmd = conn.CreateCommand();
		cmd.CommandText = @"
			SELECT title, author, genre, summary, embedding <#> @embedding AS distance
			FROM tbl_books
			ORDER BY embedding <#> @embedding ASC
			LIMIT 5;";
		cmd.Parameters.AddWithValue("@embedding", new Vector(embedding));
		await using var reader = await cmd.ExecuteReaderAsync();
		while (await reader.ReadAsync())
		{
			results.Add(new BookRecommendation
			{
				Title = reader.GetString(0),
				Author = reader.GetString(1),
				Genre = reader.IsDBNull(2) ? string.Empty : reader.GetString(2),
                Summary = reader.IsDBNull(3) ? string.Empty : reader.GetString(3),
				Reason = string.Empty // Will be filled by Ollama
			});
		}
	}

	// Generate a 250-character reason for each book using Ollama
	var ollamaGenUrl = $"http://{ollamaHost}:{ollamaPort}/api/generate";
	using (var http = new HttpClient())
	{
		for (int i = 0; i < results.Count; i++)
		{
			var book = results[i];
			var prompt = $"Given the user search: '{request.Query}', and the book: Title: '{book.Title}', Author: '{book.Author}', Genre: '{book.Genre}', Summary: '{book.Summary}', write a 250-character reason why this book is a good recommendation for the user. Only output the reason, no intro or extra text.";
			var ollamaGenReq = new { model = "llama3.2", prompt = prompt, stream = false, options = new { num_predict = 250 } };
			try
			{
				var resp = await http.PostAsJsonAsync(ollamaGenUrl, ollamaGenReq);
				if (resp.IsSuccessStatusCode)
				{
					var genResp = await resp.Content.ReadFromJsonAsync<OllamaGenerateResponse>();
					book.Reason = genResp?.Response?.Trim() ?? "";
				}
				else
				{
                    logger.LogWarning($"Failed to generate reason for book ID {book.Title}: {resp.StatusCode}");
					book.Reason = "Recommended due to high similarity to your query.";
				}
			}
			catch(Exception ex)
			{
                logger.LogWarning($"Error generating reason for book ID {book.Title}: {ex.Message}");
				book.Reason = "Recommended due to high similarity to your query.";
			}
		}
	}

	return Results.Ok(results);
});

app.Run();

// DTOs
public class SearchRequest
{
	[JsonPropertyName("query")]
	public string? Query { get; set; }
}


public class BookRecommendation
{
	public string Title { get; set; } = string.Empty;
	public string Author { get; set; } = string.Empty;
	public string Genre { get; set; } = string.Empty;
    public string Summary { get; set; } = string.Empty;
	public string Reason { get; set; } = string.Empty;
}


public class OllamaEmbeddingResponse
{
	[JsonPropertyName("embedding")]
	public float[] Embedding { get; set; } = Array.Empty<float>();
}

public class OllamaGenerateResponse
{
	[JsonPropertyName("response")]
	public string Response { get; set; } = string.Empty;
}
