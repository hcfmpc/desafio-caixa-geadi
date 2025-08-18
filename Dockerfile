# Use the official .NET 8.0 SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the project file and restore dependencies
COPY ControleArquivosGEADI.API/ControleArquivosGEADI.API.csproj ControleArquivosGEADI.API/
RUN dotnet restore "ControleArquivosGEADI.API/ControleArquivosGEADI.API.csproj"

# Copy the entire source code
COPY . .

# Build the application
WORKDIR "/src/ControleArquivosGEADI.API"
RUN dotnet build "ControleArquivosGEADI.API.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "ControleArquivosGEADI.API.csproj" -c Release -o /app/publish --no-restore

# Use the official .NET 8.0 runtime image for running
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Create a non-root user for security
RUN adduser --disabled-password --gecos '' dotnetuser && chown -R dotnetuser /app
USER dotnetuser

# Copy the published application
COPY --from=publish --chown=dotnetuser:dotnetuser /app/publish .

# Expose the port that the application will run on
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Entry point for the application
ENTRYPOINT ["dotnet", "ControleArquivosGEADI.API.dll"]
