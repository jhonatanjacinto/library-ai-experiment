-- Enable the pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create table to store book embeddings
CREATE TABLE IF NOT EXISTS tbl_books (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL, -- Reference to the MySQL book ID
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    genre TEXT, -- Genre name from MySQL
    summary TEXT,
    embedding vector(768), -- Embedding size depends on the model; nomic-embed-text = 768 dims
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_book_id UNIQUE (book_id) -- Ensure book_id is unique across the table
);

-- Optional: Index for fast vector similarity search
CREATE INDEX IF NOT EXISTS idx_books_embedding ON tbl_books
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

-- Optional: Index for genre-based filtering
CREATE INDEX IF NOT EXISTS idx_books_genre ON tbl_books (genre);