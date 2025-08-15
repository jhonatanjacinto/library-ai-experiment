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
			LIMIT 6;";
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
	// STAGE 1: Semantic filtering to get the right 3 books
	var ollamaGenUrl = $"http://{ollamaHost}:{ollamaPort}/api/generate";
	using (var http = new HttpClient())
	{
		// Step 1: Filter to 3 most appropriate books
		var booksForFiltering = results.Select((b, idx) => $"{idx + 1}. \"{b.Title}\" by {b.Author} ({b.Genre}) - {(b.Summary.Length > 100 ? b.Summary.Substring(0, 100) + "..." : b.Summary)}");

		var filterPrompt = $"""
		USER QUERY: "{request.Query}"
		
		From these 6 books, which 3 are most appropriate? 
		Important: If the user says they DON'T want something, exclude it completely.
		
		BOOKS:
		{string.Join("\n", booksForFiltering)}
		
		Respond with ONLY the 3 numbers (e.g., "2, 4, 6") of the best matches, considering semantic meaning and user preferences.
		""";

		var filterReq = new { model = "llama3.2", prompt = filterPrompt, stream = false };

		List<int> selectedIndices = new List<int>();
		try
		{
			var filterResp = await http.PostAsJsonAsync(ollamaGenUrl, filterReq);
			if (filterResp.IsSuccessStatusCode)
			{
				var filterContent = await filterResp.Content.ReadFromJsonAsync<OllamaGenerateResponse>();
				var numbersText = filterContent?.Response?.Trim() ?? "";
				logger.LogInformation($"Filter response: {numbersText}");

				// Parse the numbers (handles formats like "1, 3, 5" or "1 3 5" or "1,3,5")
				var numbers = System.Text.RegularExpressions.Regex.Matches(numbersText, @"\d+")
					.Cast<System.Text.RegularExpressions.Match>()
					.Select(m => int.Parse(m.Value))
					.Where(n => n >= 1 && n <= 6)
					.Take(3)
					.ToList();

				if (numbers.Count >= 2) // At least 2 valid selections
				{
					selectedIndices = numbers;
				}
			}
		}
		catch (Exception ex)
		{
			logger.LogWarning($"Filtering stage failed: {ex.Message}");
		}

		// Fallback if filtering failed
		if (selectedIndices.Count == 0)
		{
			selectedIndices = new List<int> { 1, 2, 3 }; // Use first 3
			logger.LogInformation("Using fallback selection: first 3 books");
		}

		// Select the filtered books
		var filteredResults = selectedIndices.Select(i => results[i - 1]).ToList();

		// STAGE 2: Generate reasons for the selected books (in parallel)
		var reasonTasks = filteredResults.Select(async book =>
		{
			var reasonPrompt = $"""
			Query: "{request.Query}"
			Book: "{book.Title}" by {book.Author}
			Genre: {book.Genre}
			Summary: {book.Summary}
			
			Write one concise sentence (max 180 chars) explaining why this book perfectly matches the user's query.
			""";

			var reasonReq = new { model = "llama3.2", prompt = reasonPrompt, stream = false };
			try
			{
				var reasonResp = await http.PostAsJsonAsync(ollamaGenUrl, reasonReq);
				if (reasonResp.IsSuccessStatusCode)
				{
					var reasonContent = await reasonResp.Content.ReadFromJsonAsync<OllamaGenerateResponse>();
					return reasonContent?.Response?.Trim() ?? "Excellent match based on semantic analysis.";
				}
			}
			catch (Exception ex)
			{
				logger.LogWarning($"Reason generation failed for {book.Title}: {ex.Message}");
			}
			return "Excellent match based on semantic analysis.";
		});

		var reasons = await Task.WhenAll(reasonTasks);

		// Assign reasons to filtered results
		for (int i = 0; i < filteredResults.Count && i < reasons.Length; i++)
		{
			filteredResults[i].Reason = reasons[i];
		}

		results = filteredResults;
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
