##See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.
#
#FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
#WORKDIR /app
#EXPOSE 80
#EXPOSE 443
#
#FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
#ARG BUILD_CONFIGURATION=Release
#WORKDIR /src
#COPY ["eBarbershop/eBarbershop.csproj", "eBarbershop/"]
#RUN dotnet restore "./eBarbershop/eBarbershop.csproj"
#COPY . .
#WORKDIR "/src/eBarbershop"
#RUN dotnet build "./eBarbershop.csproj" -c $BUILD_CONFIGURATION -o /app/build
#
#FROM build AS publish
#ARG BUILD_CONFIGURATION=Release
#RUN dotnet publish "./eBarbershop.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false
#


#FROM base AS final
#WORKDIR /app
#COPY --from=publish /app/publish .
#
#
#FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
#WORKDIR /app
#EXPOSE 7126
#ENV ASPNETCORE_URLS=http://+:7126
#
#FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
#WORKDIR /src
#COPY . .
#
#FROM build AS publish
#RUN dotnet publish "./eBarbershop.csproj" -c Release -o /app
#FROM base AS final
#WORKDIR /app
#COPY --from=publish /app .
#COPY TenisKlub/ImageBase64Files /app/ImageBase64Files
#ENTRYPOINT ["dotnet", "eBarbershop.dll"]

# Base image
# Base image
#FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
#WORKDIR /app
#EXPOSE 7126
#ENV ASPNETCORE_URLS=http://+:7126
#
## Build image
#FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
#WORKDIR /src
#
## Prvo kopiraj samo csproj i restore
#COPY eBarbershop/eBarbershop.csproj eBarbershop/
#RUN dotnet restore "eBarbershop/eBarbershop.csproj"
#
## Kopiraj ostatak koda
#COPY . .
#
## Build/publish
#WORKDIR /src/eBarbershop
#RUN dotnet publish "eBarbershop.csproj" -c Release -o /app
#
## Final image
#FROM base AS final
#WORKDIR /app
#COPY --from=build /app .
#
#ENTRYPOINT ["dotnet", "eBarbershop.dll"]

#FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
#WORKDIR /app
#EXPOSE 7126
#ENV ASPNETCORE_URLS=http://+:7126
#
#FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
#WORKDIR /src
## Kopiraj samo potrebne fajlove za restore (poboljšava caching)
#COPY ["eBarbershop/eBarbershop.csproj", "eBarbershop/"]
#COPY ["eBarbershop.Model/eBarbershop.Model.csproj", "eBarbershop.Model/"]
#RUN dotnet restore "eBarbershop/eBarbershop.csproj"
#
## Kopiraj sve ostale fajlove
#COPY . .
#WORKDIR "/src/eBarbershop"
#RUN dotnet build "eBarbershop.csproj" -c Release -o /app/build
#
#FROM build AS publish
#RUN dotnet publish "eBarbershop.csproj" -c Release -o /app/publish /p:UseAppHost=false
#
#FROM base AS final
#WORKDIR /app
#COPY --from=publish /app/publish .
#ENTRYPOINT ["dotnet", "eBarbershop.dll"]

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