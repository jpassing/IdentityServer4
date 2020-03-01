# == Build container ==========================================================
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY . .

RUN /src/clean.sh
RUN rm -rf nuget && mkdir nuget && dotnet tool restore

# Build solution with EntityFramework support
RUN dotnet build -c Release src/IdentityServer4.Ef.sln

# Publish host project
RUN dotnet publish --runtime linux-x64 --framework netcoreapp3.1 -c Release src/EntityFramework/host/Host.csproj

# == Runtime container ========================================================
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1

WORKDIR /app
COPY --from=build /src/src/EntityFramework/host/bin/Release/netcoreapp3.1/linux-x64/publish/ .

# Use CloudRun-compliant port to listen on
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
ENTRYPOINT ["dotnet", "Host.dll"] 
