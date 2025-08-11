using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace eBarbershop.Services.Extensions
{
    public static class TerminServiceExtensions
    {
        /// <summary>
        /// Automatski poziva obradu liste čekanja kada se termin otkaže ili postane dostupan
        /// </summary>
        public static async Task TriggerWaitingListProcessingAsync(this ITerminService terminService, int terminId, IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var listaCekanjaService = scope.ServiceProvider.GetService<IListaCekanjaService>();
            var logger = scope.ServiceProvider.GetService<ILogger<TerminService>>();

            if (listaCekanjaService != null)
            {
                try
                {
                    await listaCekanjaService.ProcessAvailableSlot(terminId);
                    logger?.LogInformation($"Automatski pokrenuta obrada liste čekanja za termin {terminId}");
                }
                catch (Exception ex)
                {
                    logger?.LogError(ex, $"Greška pri automatskoj obradi liste čekanja za termin {terminId}");
                }
            }
        }
    }
}