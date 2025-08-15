# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /src

# Copy csproj and restore as distinct layers (improves build cache)
COPY LibraryAI.SyncService/LibraryAI.SyncService.csproj ./LibraryAI.SyncService/
RUN dotnet restore ./LibraryAI.SyncService/LibraryAI.SyncService.csproj

# Copy the rest of the source code
COPY LibraryAI.SyncService/. ./LibraryAI.SyncService/

WORKDIR /src/LibraryAI.SyncService
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS final
WORKDIR /app
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "LibraryAI.SyncService.dll"]