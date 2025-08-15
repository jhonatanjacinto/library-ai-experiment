# LibraryAI

LibraryAI is a sample application and proof of concept created solely for study purposes. The main intent is to build a book recommendations API that generates suggestions based on a user prompt and the data available in the MySQL database, which serves as the source of truth for the app. The project leverages modern vector databases and large language models for advanced document search, embedding, and synchronization across multiple data sources. It is fully containerized for easy deployment and development, supporting both PostgreSQL (with pgvector) and MySQL backends, and integrates with Ollama for local LLM and embedding model inference.

## Features

- AI-powered document search using vector embeddings (via pgvector and Ollama)
- Synchronization service to keep data consistent between MySQL and PostgreSQL
- RESTful Web API for library operations
- Containerized architecture for easy setup and deployment

## Getting Started

### 1. Clone the Repository

```bash
git clone <YOUR_GITHUB_REPO_URL>
cd LibraryAI
```

### 2. Prerequisites

- Docker and Docker Compose
- (Optional) .NET 9 SDK for local development

### 3. Running the Project

To start all services (PostgreSQL, MySQL, Ollama, API, and Sync Service):

```bash
docker compose up --build
```

- The API will be available at [http://localhost:5000](http://localhost:5000)
- Ollama and databases are only accessible within the Docker network for security

### 4. Stopping the Project

```bash
docker compose down
```

## Project Structure

- `LibraryAI.WebApi/` - ASP.NET Core Web API for library operations
- `LibraryAI.SyncService/` - Background worker for synchronizing data between MySQL and PostgreSQL
- `docker/` - Initialization scripts for databases
- `docker-compose.yml` - Orchestrates all services

## Technologies Used

| Technology         | Usage                                                                 |
|-------------------|-----------------------------------------------------------------------|
| .NET 9            | Backend for API and Sync Service (C#)                                 |
| ASP.NET Core      | Web API implementation                                                |
| Docker            | Containerization of all services                                      |
| Docker Compose    | Multi-service orchestration                                           |
| PostgreSQL        | Vector database backend (with pgvector)                               |
| MySQL             | Relational database backend                                           |
| Ollama            | Local LLM and embedding model server                                  |
| pgvector          | PostgreSQL extension for vector similarity search                     |

## How Technologies Are Used

- **.NET 9 / ASP.NET Core**: Implements the API (`LibraryAI.WebApi`) and background sync worker (`LibraryAI.SyncService`).
- **Docker & Compose**: All components (API, Sync Service, databases, Ollama) run as containers for easy setup and isolation.
- **PostgreSQL + pgvector**: Stores document embeddings for semantic search.
- **MySQL**: Used as a source database for synchronization.
- **Ollama**: Provides local inference for LLMs and embedding models, used by the API and Sync Service.
- **Database Init Scripts**: Located in `docker/init/` for both MySQL and PostgreSQL, automatically run on first container startup.

## Customization

- Update environment variables in `docker-compose.yml` as needed for database credentials or ports.
- Add your own LLM or embedding models to Ollama by modifying the `entrypoint` in the Ollama service.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

*Feel free to contribute or open issues to improve LibraryAI!*
