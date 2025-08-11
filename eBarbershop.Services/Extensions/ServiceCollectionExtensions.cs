using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting; 
using Microsoft.ML;

namespace eBarbershop.Services.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddWaitingListServices(this IServiceCollection services)
        {
            // ML servisi
            services.AddSingleton<MLContext>();
            services.AddScoped<IWaitingListMLService, WaitingListMLService>();

            // Glavni servisi
            services.AddScoped<IListaCekanjaService, ListaCekanjaService>();
            services.AddScoped<IWaitingListAnalyticsService, WaitingListAnalyticsService>();

            // Background servisi - sada treba raditi
            services.AddHostedService<WaitingListBackgroundService>();

            return services;
        }
    }
}