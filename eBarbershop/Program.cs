using eBarbershop;
using eBarbershop.Services;
using eBarbershop.Services.Database;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using RabbitMQ.Client;


static async Task WaitForDatabase(IServiceProvider services)
{
    var cfg = services.GetRequiredService<IConfiguration>();
    var full = cfg.GetConnectionString("DefaultConnection");       // sadr�i ebarbershopDB
    var masterConn = new SqlConnectionStringBuilder(full)           // kloniramo
    { InitialCatalog = "master" }                  // promijenimo bazu
                     .ConnectionString;

    const string dbName = "ebarbershopDB";
    const int maxAttempts = 30;
    var delay = TimeSpan.FromSeconds(2);

    for (int i = 1; i <= maxAttempts; i++)
    {
        try
        {
            Console.WriteLine($"[WaitForDb] Try {i}/{maxAttempts}");
            await using var conn = new SqlConnection(masterConn);
            await conn.OpenAsync();

            // postoji li ve� baza?
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = $"SELECT db_id('{dbName}')";
            var id = await cmd.ExecuteScalarAsync();

            if (id == null || id == DBNull.Value)
            {
                Console.WriteLine($"[WaitForDb] Creating database {dbName}�");
                cmd.CommandText = $"CREATE DATABASE [{dbName}]";
                await cmd.ExecuteNonQueryAsync();
            }

            Console.WriteLine("[WaitForDb] Database is ready!");
            return;                           // zavr�ili smo
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[WaitForDb] Not ready: {ex.Message}");
            await Task.Delay(delay);
        }
    }

    throw new Exception("Database not ready after multiple attempts.");
}




var builder = WebApplication.CreateBuilder(args);

builder.Services.AddTransient<IProizvodService, ProizvodService>();
builder.Services.AddTransient<IKorisniciService, KorisniciService>();
builder.Services.AddTransient<IGradService, GradService>();
builder.Services.AddTransient<IDrzavaService, DrzavaService>();
builder.Services.AddTransient<IVrstaProizvodaService, VrstaProizvodaService>();
builder.Services.AddTransient<IUslugaService, UslugaService>();
builder.Services.AddTransient<IUplataService, UplataService>();
builder.Services.AddTransient<IUlogaService, UlogaService>();
builder.Services.AddTransient<ITerminService, TerminService>();
builder.Services.AddTransient<INarudzbaService, NarudzbaService>();
builder.Services.AddTransient<IRezervacijaService, RezervacijaService>();
builder.Services.AddTransient<IRecenzijaService, RecenzijaService>();
builder.Services.AddTransient<INovostService, NovostService>();
builder.Services.AddTransient<IMailService, MailService>();


// Add these to your DI container
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();

builder.Services.AddControllers();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
});


builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new OpenApiSecurityScheme()
    {
        Type = SecuritySchemeType.Http,
        Scheme = "basic"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"},

            },
            new string[]{}
    }});
});

var test = builder.Configuration.GetConnectionString("DefaultConnection");

var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection") ??
                     builder.Configuration.GetConnectionString("DefaultConnection");


builder.Services.AddDbContext<EBarbershop1Context>(
  dbContextOpcije => dbContextOpcije
    .UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"), sqlServerOptions => sqlServerOptions.EnableRetryOnFailure()));

builder.Services.AddAutoMapper(typeof(IKorisniciService));
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

string hostname = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "127.0.0.1";
string username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
string password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
string virtualHost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

builder.Services.AddSingleton<IConnection>(sp =>
{
    var factory = new ConnectionFactory
    {
        HostName = hostname,
        UserName = username,
        Password = password,
        VirtualHost = virtualHost,
        DispatchConsumersAsync = true
    };
    return factory.CreateConnection();
});

var app = builder.Build();
await WaitForDatabase(app.Services);
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<EBarbershop1Context>();
    dbContext.Database.Migrate();

    SeedDbInitializer.Seed(dbContext);
}


if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");

app.UseHttpsRedirection();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();