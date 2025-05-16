using eBarbershop;
using eBarbershop.Services;
using eBarbershop.Services.Database;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using RabbitMQ.Client;

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

builder.Services.AddDbContext<EBarbershop1Context>(
  dbContextOpcije => dbContextOpcije
    .UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

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