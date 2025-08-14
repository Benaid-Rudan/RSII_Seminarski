using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class WaitingListHealthCheck : IHealthCheck
    {
        private readonly EBarbershop1Context _context;
        private readonly ILogger<WaitingListHealthCheck> _logger;

        public WaitingListHealthCheck(EBarbershop1Context context, ILogger<WaitingListHealthCheck> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            try
            {
                // Provjeri broj aktivnih stavki liste čekanja
                //var activeItems = await _context.ListaCekanja.CountAsync(l => l.Status == 1, cancellationToken);

                // Provjeri broj neodgovorenih notifikacija
                var pendingNotifications = await _context.NotifikacijaListeCekanja
                    .CountAsync(n => !n.Odgovoreno && n.DatumIsteka > DateTime.Now, cancellationToken);

                var data = new Dictionary<string, object>
                {
                    //{ "ActiveWaitingListItems", activeItems },
                    { "PendingNotifications", pendingNotifications },
                    { "Timestamp", DateTime.UtcNow }
                };

                if (
                    //activeItems > 1000 ||
                    pendingNotifications > 100)
                {
                    return HealthCheckResult.Degraded(
                        "Visok broj aktivnih stavki ili notifikacija",
                        data: data);
                }

                return HealthCheckResult.Healthy(
                    "Waiting list sistem radi normalno",
                    data: data);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Health check failed for waiting list");
                return HealthCheckResult.Unhealthy(
                    "Greška pri health check waiting list sistema",
                    ex);
            }
        }
    }
}