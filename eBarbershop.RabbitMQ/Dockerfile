FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Kopiraj samo potrebne .csproj fajlove
COPY eBarbershop.RabbitMQ/eBarbershop.RabbitMQ.csproj eBarbershop.RabbitMQ/
RUN dotnet restore eBarbershop.RabbitMQ/eBarbershop.RabbitMQ.csproj

# Kopiraj ostatak
COPY . .

# Build projekta
WORKDIR /src/eBarbershop.RabbitMQ
RUN dotnet build -c Release -o /app/build

FROM mcr.microsoft.com/dotnet/runtime:6.0 AS runtime
WORKDIR /app
COPY --from=build /app/build .

ENTRYPOINT ["dotnet", "eBarbershop.RabbitMQ.dll"]
