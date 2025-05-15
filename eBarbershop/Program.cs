using eBarbershop;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using eBarbershop.Services.Database;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;

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
//builder.Services.AddTransient<NotificationRabbitService, NotificationRabbitService>();
builder.Services.AddTransient<IMailService, MailService>();
//builder.Services.AddScoped<IKorisniciService, KorisniciService>();
builder.Services.AddScoped<INotificationRabbitService, NotificationRabbitService>();


// Add these to your DI container
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<INotificationService, NotificationService>();

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
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
    });
    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"},

            },
            new string[]{}
    }});
});

var konekcijskiString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<EBarbershop1Context>(
  dbContextOpcije => dbContextOpcije
    .UseSqlServer(konekcijskiString));

builder.Services.AddAutoMapper(typeof(IKorisniciService));
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication",null);

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


var connection = app.Services.GetRequiredService<IConnection>();
using var channel = connection.CreateModel();

channel.QueueDeclare("notifications", durable: true, exclusive: false, autoDelete: false);

Console.WriteLine(" [*] Waiting for messages.");

var consumer = new AsyncEventingBasicConsumer(channel);
consumer.Received += async (model, ea) =>
{
    try
    {
        var body = ea.Body.ToArray();
        var message = Encoding.UTF8.GetString(body);
        var notification = JsonSerializer.Deserialize<NotificationUpsertRequest>(message);

        using var scope = app.Services.CreateScope();
        var service = scope.ServiceProvider.GetRequiredService<INotificationService>();

        await service.Insert(notification);

        channel.BasicAck(ea.DeliveryTag, false);
    }
    catch (Exception ex)
    {
        // Log error and reject message
        channel.BasicNack(ea.DeliveryTag, false, true);
    }
};

channel.BasicConsume("notifications", false, consumer);
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

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<EBarbershop1Context>();
        var logger = services.GetRequiredService<ILogger<Program>>();

        logger.LogInformation("Attempting database connection and migrations...");

        bool isDatabaseAvailable = false;
        int retries = 0;
        while (!isDatabaseAvailable && retries < 10)
        {
            try
            {
                context.Database.CanConnect();
                isDatabaseAvailable = true;
                logger.LogInformation("Database connection established successfully.");
            }
            catch (Exception ex)
            {
                retries++;
                logger.LogWarning($"Database connection attempt {retries} failed: {ex.Message}");
                System.Threading.Thread.Sleep(5000);
            }
        }

        if (isDatabaseAvailable)
        {
            logger.LogInformation("Applying migrations...");
            context.Database.Migrate();

            if (!context.Drzava.Any())
            {
                logger.LogInformation("Seeding database...");
                SeedDbInitializer.Seed(context);
                logger.LogInformation("Database seeded successfully.");
            }
        }
        else
        {
            logger.LogError("Could not connect to the database after multiple attempts.");
        }
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while initializing the database.");
    }
}






app.Run();
