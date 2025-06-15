using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using eBarbershop.Services.Database;

namespace eBarbershop.Services
{
    public class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<EBarbershop1Context>
    {
        public EBarbershop1Context CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<EBarbershop1Context>();
            optionsBuilder.UseSqlServer("Server=localhost;Database=benaidfinal;User=sa;Password=Password1;TrustServerCertificate=True;Encrypt=false;MultipleActiveResultSets=true");

            return new EBarbershop1Context(optionsBuilder.Options);
        }
    }
}