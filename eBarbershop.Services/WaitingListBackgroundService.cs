using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class WaitingListBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _services;
        private readonly ILogger<WaitingListBackgroundService> _logger;
        private readonly TimeSpan _period = TimeSpan.FromMinutes(15); // Izvršava se svakih 15 minuta

        public WaitingListBackgroundService(IServiceProvider services, ILogger<WaitingListBackgroundService> logger)
        {
            _services = services;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            using var timer = new PeriodicTimer(_period);

            while (!stoppingToken.IsCancellationRequested && await timer.WaitForNextTickAsync(stoppingToken))
            {
                try
                {
                    await ProcessWaitingListTasks();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred during waiting list background processing");
                }
            }
        }

        private async Task ProcessWaitingListTasks()
        {
            using var scope = _services.CreateScope();
            var listaCekanjaService = scope.ServiceProvider.GetRequiredService<IListaCekanjaService>();
            var mlService = scope.ServiceProvider.GetRequiredService<IWaitingListMLService>();

            _logger.LogInformation("Starting waiting list background processing");

            // 1. Obradi istekle notifikacije
            await listaCekanjaService.ProcessExpiredNotifications();

            // 2. Optimizuj redoslijed liste čekanja (jednom dnevno)
            if (DateTime.Now.Hour == 2 && DateTime.Now.Minute < 15) // 2:00 AM
            {
                await listaCekanjaService.OptimizeWaitingListOrder();

                // Retrain ML model jednom sedmično (nedjeljom)
                if (DateTime.Now.DayOfWeek == DayOfWeek.Sunday)
                {
                    await mlService.RetrainModel();
                    _logger.LogInformation("ML model retrained");
                }
            }

            // 3. Provjeri dostupne termite i automatski proces notifikacije
            await ProcessAvailableSlots(scope);

            _logger.LogInformation("Waiting list background processing completed");
        }

        private async Task ProcessAvailableSlots(IServiceScope scope)
        {
            var terminService = scope.ServiceProvider.GetRequiredService<ITerminService>();
            var listaCekanjaService = scope.ServiceProvider.GetRequiredService<IListaCekanjaService>();

            // Pronađi sve dostupne termine za narednih 7 dana
            var dostupniTermini = await terminService.Get(new Model.SearchObjects.TerminSearchObject
            {
                isBooked = false,
                DatumOd = DateTime.Today,
                DatumDo = DateTime.Today.AddDays(7),
                IncludeKorisnik = true
            });

            foreach (var termin in dostupniTermini)
            {
                try
                {
                    await listaCekanjaService.ProcessAvailableSlot(termin.TerminId);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, $"Error processing available slot {termin.TerminId}");
                }
            }
        }
    }
}