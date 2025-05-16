#Use the .NET 8 SDK for building the project,
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim AS base

#Copy all project files,
COPY ["eBarbershop/", "eBarbershop/"]
COPY ["eBarbershop.Model/", "eBarbershop.Model/"]
COPY ["eBarbershop.Services/", "eBarbershop.Services/"]
COPY ["eBarbershop.RabbitMQ/", "eBarbershop.RabbitMQ/"]

#Build and publish the project,
WORKDIR /eBarbershop
RUN dotnet publish --configuration Release --output /out --property WarningLevel=0

#Use the .NET 8 ASP.NET runtime for running the application,
FROM mcr.microsoft.com/dotnet/aspnet:8.0-bookworm-slim AS final

EXPOSE 80

ENV ASPNETCORE_URLS="http://+"
ENV ASPNETCORE_ENVIRONMENT="Development"

#Copy the published application from the build stage,
COPY --from=base /out /app/

#Define the entry point for the container,
ENTRYPOINT ["dotnet", "/app/eBarbershop.dll"]