using eBarbershop.Model.SearchObjects;
using eBarbershop.Services;
using eBarbershop.Services.Database;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IProizvodiService, ProizvodiService>();
builder.Services.AddTransient<IKorisniciService, KorisniciService>();
builder.Services.AddTransient<IGradService, GradService>();
builder.Services.AddTransient<IService<eBarbershop.Model.Drzava,BaseSearchObject>, BaseService<eBarbershop.Model.Drzava, eBarbershop.Services.Database.Drzava, BaseSearchObject>>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var konekcijskiString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<EBarbershop1Context>(
  dbContextOpcije => dbContextOpcije
    .UseSqlServer(konekcijskiString));

builder.Services.AddAutoMapper(typeof(IKorisniciService));


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}



app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
