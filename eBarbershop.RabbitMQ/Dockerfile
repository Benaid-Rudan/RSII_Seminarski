FROM mcr.microsoft.com/dotnet/sdk:8.0.100 AS build
WORKDIR /src

#Copy projects for dependency resolution,
COPY ["eBarbershop.RabbitMQ/eBarbershop.RabbitMQ.csproj", "eBarbershop.RabbitMQ/"]
COPY ["eBarbershop.Model/eBarbershop.Model.csproj", "eBarbershop.Model/"]
COPY ["eBarbershop.Services/eBarbershop.Services.csproj", "eBarbershop.Services/"]
COPY ["eBarbershop/eBarbershop.csproj", "eBarbershop/"]

#Restore dependencies,
RUN dotnet restore "eBarbershop.RabbitMQ/eBarbershop.RabbitMQ.csproj"

#Copy everything else and build,
COPY . .
WORKDIR "/src/eBarbershop.RabbitMQ"
RUN dotnet publish "eBarbershop.RabbitMQ.csproj" -c Release -o /app/publish /p:UseAppHost=false

#Build runtime image,
FROM mcr.microsoft.com/dotnet/aspnet:8.0.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "eBarbershop.RabbitMQ.dll"]