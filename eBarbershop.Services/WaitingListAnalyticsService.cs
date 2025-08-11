using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public interface IWaitingListAnalyticsService
    {
        Task<WaitingListAnalytics> GetAnalytics(int? frizerId = null, DateTime? fromDate = null, DateTime? toDate = null);
        Task<List<PeakTimeAnalysis>> GetPeakTimesAnalysis(int? frizerId = null);
        Task<CustomerBehaviorAnalysis> GetCustomerBehaviorAnalysis(int klijentId);
        Task<List<RecommendationEffectiveness>> GetRecommendationEffectiveness();
    }

    public class WaitingListAnalytics
    {
        public int TotalWaitingListEntries { get; set; }
        public double AverageWaitTime { get; set; }
        public double AcceptanceRate { get; set; }
        public double ExpiredRate { get; set; }
        public double CancellationRate { get; set; }
        public List<DailyStats> DailyStats { get; set; }
        public List<ServicePopularity> MostRequestedServices { get; set; }
        public List<BarberEfficiency> BarberEfficiencyStats { get; set; }
    }

    public class DailyStats
    {
        public DateTime Date { get; set; }
        public int NewEntries { get; set; }
        public int Notifications { get; set; }
        public int Acceptances { get; set; }
        public int Expirations { get; set; }
    }

    public class ServicePopularity
    {
        public int UslugaId { get; set; }
        public string NazivUsluge { get; set; }
        public int BrojZahtjeva { get; set; }
        public double PostotakPrihvacanja { get; set; }
        public double ProsjekVrijemeCekanja { get; set; }
    }

    public class BarberEfficiency
    {
        public int FrizerId { get; set; }
        public string ImeFrizera { get; set; }
        public int BrojZahtjeva { get; set; }
        public double PostotakPrihvacanja { get; set; }
        public double ProsjekVrijemeOdziva { get; set; }
        public double MLSkorTocnost { get; set; }
    }

    public class PeakTimeAnalysis
    {
        public int Sat { get; set; }
        public DayOfWeek DanUNedelji { get; set; }
        public int BrojZahtjeva { get; set; }
        public double PostotakPrihvacanja { get; set; }
        public double ProsjekVrijemeCekanja { get; set; }
    }

    public class CustomerBehaviorAnalysis
    {
        public int KlijentId { get; set; }
        public double ProsjekVrijemeCekanja { get; set; }
        public double PostotakPrihvacanja { get; set; }
        public List<PreferredTimeSlot> OmiljeniTermini { get; set; }
        public List<PreferredBarber> OmiljeniFrizeri { get; set; }
        public double FleksibilnostSkala { get; set; } // 0-1, gdje 1 znači vrlo fleksibilan
    }

    public class PreferredTimeSlot
    {
        public TimeSpan Vrijeme { get; set; }
        public int Frekvencija { get; set; }
    }

    public class PreferredBarber
    {
        public int FrizerId { get; set; }
        public string ImeFrizera { get; set; }
        public int BrojRezervacija { get; set; }
    }

    public class RecommendationEffectiveness
    {
        public DateTime Datum { get; set; }
        public double MLSkorTocnost { get; set; }
        public double PredvidjenaVsPravaStopaPrihvacanja { get; set; }
        public int BrojTestova { get; set; }
    }

    public class WaitingListAnalyticsService : IWaitingListAnalyticsService
    {
        private readonly EBarbershop1Context _context;

        public WaitingListAnalyticsService(EBarbershop1Context context)
        {
            _context = context;
        }

        public async Task<WaitingListAnalytics> GetAnalytics(int? frizerId = null, DateTime? fromDate = null, DateTime? toDate = null)
        {
            var query = _context.ListaCekanja.AsQueryable();

            if (frizerId.HasValue)
                query = query.Where(w => w.FrizerId == frizerId.Value);

            if (fromDate.HasValue)
                query = query.Where(w => w.DatumPrijave >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(w => w.DatumPrijave <= toDate.Value);

            var totalEntries = await query.CountAsync();

            var completedEntries = query.Where(w => w.Status != 1); // Ne aktivne

            var averageWaitTime = await completedEntries
                .Where(w => w.DatumNotifikacije.HasValue)
                .AverageAsync(w => (double?)(w.DatumNotifikacije.Value - w.DatumPrijave).TotalDays) ?? 0;

            var acceptanceRate = await completedEntries
                .AverageAsync(w => w.Status == 3 ? 1.0 : 0.0); // Status 3 = Prihvacena

            var expiredRate = await completedEntries
                .AverageAsync(w => w.Status == 4 ? 1.0 : 0.0); // Status 4 = Istekla

            var cancellationRate = await completedEntries
                .AverageAsync(w => w.Status == 5 ? 1.0 : 0.0); // Status 5 = Otkazana

            // Dnevne statistike
            var dailyStats = await query
                .GroupBy(w => w.DatumPrijave.Date)
                .Select(g => new DailyStats
                {
                    Date = g.Key,
                    NewEntries = g.Count(),
                    Notifications = g.Count(w => w.Status >= 2),
                    Acceptances = g.Count(w => w.Status == 3),
                    Expirations = g.Count(w => w.Status == 4)
                })
                .OrderBy(d => d.Date)
                .ToListAsync();

            // Popularnost usluga
            var servicePopularity = await query
                .Include(w => w.Usluga)
                .GroupBy(w => new { w.UslugaId, w.Usluga.Naziv })
                .Select(g => new ServicePopularity
                {
                    UslugaId = g.Key.UslugaId,
                    NazivUsluge = g.Key.Naziv,
                    BrojZahtjeva = g.Count(),
                    PostotakPrihvacanja = g.Average(w => w.Status == 3 ? 1.0 : 0.0),
                    ProsjekVrijemeCekanja = g.Where(w => w.DatumNotifikacije.HasValue)
                        .Average(w => (double?)(w.DatumNotifikacije.Value - w.DatumPrijave).TotalDays) ?? 0
                })
                .OrderByDescending(s => s.BrojZahtjeva)
                .Take(10)
                .ToListAsync();

            // Efikasnost frizera
            var barberEfficiency = await query
                .Include(w => w.Frizer)
                .GroupBy(w => new { w.FrizerId, w.Frizer.Ime, w.Frizer.Prezime })
                .Select(g => new BarberEfficiency
                {
                    FrizerId = g.Key.FrizerId,
                    ImeFrizera = g.Key.Ime + " " + g.Key.Prezime,
                    BrojZahtjeva = g.Count(),
                    PostotakPrihvacanja = g.Average(w => w.Status == 3 ? 1.0 : 0.0),
                    ProsjekVrijemeOdziva = g.Where(w => w.DatumNotifikacije.HasValue)
                        .Average(w => (double?)(w.DatumNotifikacije.Value - w.DatumPrijave).TotalHours) ?? 0,
                    MLSkorTocnost = g.Average(w => w.MLSkor)
                })
                .OrderByDescending(b => b.PostotakPrihvacanja)
                .ToListAsync();

            return new WaitingListAnalytics
            {
                TotalWaitingListEntries = totalEntries,
                AverageWaitTime = averageWaitTime,
                AcceptanceRate = acceptanceRate,
                ExpiredRate = expiredRate,
                CancellationRate = cancellationRate,
                DailyStats = dailyStats,
                MostRequestedServices = servicePopularity,
                BarberEfficiencyStats = barberEfficiency
            };
        }

        public async Task<List<PeakTimeAnalysis>> GetPeakTimesAnalysis(int? frizerId = null)
        {
            var query = _context.ListaCekanja
                .Where(w => w.ZeljenoVrijeme.HasValue);

            if (frizerId.HasValue)
                query = query.Where(w => w.FrizerId == frizerId.Value);

            return await query
                .GroupBy(w => new {
                    Sat = w.ZeljenoVrijeme.Value.Hours,
                    Dan = w.ZeljeniDatum.DayOfWeek
                })
                .Select(g => new PeakTimeAnalysis
                {
                    Sat = g.Key.Sat,
                    DanUNedelji = g.Key.Dan,
                    BrojZahtjeva = g.Count(),
                    PostotakPrihvacanja = g.Average(w => w.Status == 3 ? 1.0 : 0.0),
                    ProsjekVrijemeCekanja = g.Where(w => w.DatumNotifikacije.HasValue)
                        .Average(w => (double?)(w.DatumNotifikacije.Value - w.DatumPrijave).TotalDays) ?? 0
                })
                .OrderByDescending(p => p.BrojZahtjeva)
                .ToListAsync();
        }

        public async Task<CustomerBehaviorAnalysis> GetCustomerBehaviorAnalysis(int klijentId)
        {
            var customerWaitingList = await _context.ListaCekanja
                .Include(w => w.Frizer)
                .Where(w => w.KlijentId == klijentId)
                .ToListAsync();

            if (!customerWaitingList.Any())
            {
                return new CustomerBehaviorAnalysis { KlijentId = klijentId };
            }

            var avgWaitTime = customerWaitingList
                .Where(w => w.DatumNotifikacije.HasValue)
                .Average(w => (w.DatumNotifikacije.Value - w.DatumPrijave).TotalDays);

            var acceptanceRate = customerWaitingList
                .Average(w => w.Status == 3 ? 1.0 : 0.0);

            var preferredTimes = customerWaitingList
                .Where(w => w.ZeljenoVrijeme.HasValue)
                .GroupBy(w => w.ZeljenoVrijeme.Value)
                .Select(g => new PreferredTimeSlot
                {
                    Vrijeme = g.Key,
                    Frekvencija = g.Count()
                })
                .OrderByDescending(p => p.Frekvencija)
                .ToList();

            var preferredBarbers = customerWaitingList
                .GroupBy(w => new { w.FrizerId, w.Frizer.Ime, w.Frizer.Prezime })
                .Select(g => new PreferredBarber
                {
                    FrizerId = g.Key.FrizerId,
                    ImeFrizera = g.Key.Ime + " " + g.Key.Prezime,
                    BrojRezervacija = g.Count()
                })
                .OrderByDescending(p => p.BrojRezervacija)
                .ToList();

            var flexibility = customerWaitingList.Average(w => w.ZeljenoVrijeme.HasValue ? 0.3 : 1.0);

            return new CustomerBehaviorAnalysis
            {
                KlijentId = klijentId,
                ProsjekVrijemeCekanja = avgWaitTime,
                PostotakPrihvacanja = acceptanceRate,
                OmiljeniTermini = preferredTimes,
                OmiljeniFrizeri = preferredBarbers,
                FleksibilnostSkala = flexibility
            };
        }

        public async Task<List<RecommendationEffectiveness>> GetRecommendationEffectiveness()
        {
            return await _context.NotifikacijaListeCekanja
                .Include(n => n.ListaCekanja)
                .Where(n => n.Odgovoreno)
                .GroupBy(n => n.DatumNotifikacije.Date)
                .Select(g => new RecommendationEffectiveness
                {
                    Datum = g.Key,
                    MLSkorTocnost = g.Average(n => n.ListaCekanja.MLSkor),
                    PredvidjenaVsPravaStopaPrihvacanja = Math.Abs(
                        g.Average(n => n.ListaCekanja.MLSkor) -
                        g.Average(n => n.Prihvaceno ? 1.0 : 0.0)
                    ),
                    BrojTestova = g.Count()
                })
                .OrderBy(r => r.Datum)
                .ToListAsync();
        }
    }
}