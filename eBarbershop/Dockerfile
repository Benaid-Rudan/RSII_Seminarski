FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 7126
ENV ASPNETCORE_URLS=http://+:7126

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy all project files
COPY ["eBarbershop/eBarbershop.csproj", "eBarbershop/"]
COPY ["eBarbershop.Model/eBarbershop.Model.csproj", "eBarbershop.Model/"]
COPY ["eBarbershop.Services/eBarbershop.Services.csproj", "eBarbershop.Services/"]
COPY ["eBarbershop.RabbitMQ/eBarbershop.RabbitMQ.csproj", "eBarbershop.RabbitMQ/"]

# Restore packages
RUN dotnet restore "eBarbershop/eBarbershop.csproj"

# Copy everything else
COPY . .

# Build
WORKDIR "/src/eBarbershop"
RUN dotnet build "eBarbershop.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "eBarbershop.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "eBarbershop.dll", "--migrate"]