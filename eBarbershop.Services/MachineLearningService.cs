using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Services.Database;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using Microsoft.EntityFrameworkCore;

namespace eBarbershop.Services
{
    public interface IMachineLearningService
    {
        Task<List<Model.PreporukaTermina>> GenerateRecommendations(int klijentId, int uslugaId, List<Model.Rezervacija> historija);
        Task<Model.PredvidjanjeZauzetosti> PredictBusyness(int korisnikId, DateTime datum, List<Model.Termin> historija);
    }

    public class MachineLearningService : IMachineLearningService
    {
        private readonly EBarbershop1Context _context;
        private readonly IMapper _mapper;
        private readonly MLContext _mlContext;

        public MachineLearningService(EBarbershop1Context context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
            _mlContext = new MLContext(seed: 1);
        }

        public async Task<List<Model.PreporukaTermina>> GenerateRecommendations(int klijentId, int uslugaId, List<Model.Rezervacija> historija)
        {
            // Detect haircut frequency pattern
            var detectedInterval = await DetectHaircutFrequency(klijentId);
            var defaultInterval = TimeSpan.FromDays(7);

            // Get last completed appointment
            var lastAppointmentDate = await GetLastCompletedAppointmentDate(klijentId);

            DateTime minRecommendationDate = DateTime.Now.Date;

            if (lastAppointmentDate.HasValue)
            {
                var interval = detectedInterval ?? defaultInterval;
                minRecommendationDate = lastAppointmentDate.Value.Date.Add(interval);

                if (minRecommendationDate < DateTime.Now.Date)
                {
                    minRecommendationDate = DateTime.Now.Date;
                }
            }

            // Look 30 days ahead for availability
            var startDate = minRecommendationDate;
            var endDate = startDate.AddDays(30);

            var existingAppointments = await _context.Termin
                .Where(t => t.Vrijeme >= startDate && t.Vrijeme <= endDate)
                .ToListAsync();

            // Prepare training data
            var trainingData = await PrepareRecommendationTrainingData(klijentId);

            // Define recommendation pipeline
            var pipeline = _mlContext.Transforms.Conversion.MapValueToKey(
                    outputColumnName: "ClientIdEncoded",
                    inputColumnName: nameof(AppointmentRecommendationData.ClientId))
                .Append(_mlContext.Transforms.Conversion.MapValueToKey(
                    outputColumnName: "BarberIdEncoded",
                    inputColumnName: nameof(AppointmentRecommendationData.BarberId)))
                .Append(_mlContext.Recommendation().Trainers.MatrixFactorization(
                    new MatrixFactorizationTrainer.Options
                    {
                        MatrixColumnIndexColumnName = "ClientIdEncoded",
                        MatrixRowIndexColumnName = "BarberIdEncoded",
                        LabelColumnName = "Label",
                        LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                        Alpha = 0.01,
                        Lambda = 0.025,
                        NumberOfIterations = 100
                    }));

            // Train model
            var model = pipeline.Fit(trainingData);

            // Get all barbers
            var allBarbers = await _context.Korisnik
                .Where(k => k.KorisnikId == 2)
                .ToListAsync();

            var recommendations = new List<Model.PreporukaTermina>();
            var predictionEngine = _mlContext.Model.CreatePredictionEngine<AppointmentRecommendationData, AppointmentPrediction>(model);

            foreach (var barber in allBarbers)
            {
                var barberModel = _mapper.Map<Model.Korisnik>(barber);

                // Generate recommendations based on detected interval first
                if (detectedInterval.HasValue && lastAppointmentDate.HasValue)
                {
                    var idealDate = lastAppointmentDate.Value.Add(detectedInterval.Value);
                    if (idealDate >= startDate && idealDate <= endDate)
                    {
                        var dayOfWeek = (float)idealDate.DayOfWeek;

                        for (int hour = 9; hour <= 17; hour++)
                        {
                            var proposedTime = new DateTime(idealDate.Year, idealDate.Month, idealDate.Day, hour, 0, 0);

                            if (!existingAppointments.Any(a => a.KorisnikID == barber.KorisnikId && a.Vrijeme == proposedTime))
                            {
                                var input = new AppointmentRecommendationData
                                {
                                    ClientId = klijentId,
                                    BarberId = barber.KorisnikId,
                                    ServiceId = uslugaId,
                                    DayOfWeek = dayOfWeek,
                                    TimeOfDay = hour,
                                    Label = 1
                                };

                                var prediction = predictionEngine.Predict(input);

                                if (prediction.Score > 0.7)
                                {
                                    recommendations.Add(new Model.PreporukaTermina
                                    {
                                        KlijentId = klijentId,
                                        KorisnikId = barber.KorisnikId,
                                        UslugaId = uslugaId,
                                        PreporuceniTermin = proposedTime,
                                        SkorPovjerenja = prediction.Score,
                                        RazlogPreporuke = GetRecommendationReason(prediction.Score, barberModel, detectedInterval, lastAppointmentDate),
                                        IsAccepted = false
                                    });
                                }
                            }
                        }
                    }
                }

                // Also include other available slots
                for (int daysFromNow = 0; daysFromNow <= (endDate - startDate).Days; daysFromNow++)
                {
                    var date = startDate.AddDays(daysFromNow).Date;
                    if (date < DateTime.Now.Date) continue;

                    var dayOfWeek = (float)date.DayOfWeek;

                    for (int hour = 9; hour <= 17; hour++)
                    {
                        var proposedTime = new DateTime(date.Year, date.Month, date.Day, hour, 0, 0);

                        if (existingAppointments.Any(a => a.KorisnikID == barber.KorisnikId && a.Vrijeme == proposedTime))
                        {
                            continue;
                        }

                        var input = new AppointmentRecommendationData
                        {
                            ClientId = klijentId,
                            BarberId = barber.KorisnikId,
                            ServiceId = uslugaId,
                            DayOfWeek = dayOfWeek,
                            TimeOfDay = hour,
                            Label = 1
                        };

                        var prediction = predictionEngine.Predict(input);

                        if (prediction.Score > 0.7)
                        {
                            recommendations.Add(new Model.PreporukaTermina
                            {
                                KlijentId = klijentId,
                                KorisnikId = barber.KorisnikId,
                                UslugaId = uslugaId,
                                PreporuceniTermin = proposedTime,
                                SkorPovjerenja = prediction.Score,
                                RazlogPreporuke = GetRecommendationReason(prediction.Score, barberModel, detectedInterval, lastAppointmentDate),
                                IsAccepted = false
                            });
                        }
                    }
                }
            }

            return recommendations
                .OrderBy(r => Math.Abs((r.PreporuceniTermin - (lastAppointmentDate?.Add(detectedInterval ?? defaultInterval) ?? DateTime.MaxValue)).Ticks))
                .ThenByDescending(r => r.SkorPovjerenja)
                .ToList();

        }

        private async Task<TimeSpan?> DetectHaircutFrequency(int klijentId)
        {
            var appointments = await _context.Termin
                .Where(t => t.KlijentId == klijentId)
                .OrderBy(t => t.Vrijeme)
                .ToListAsync();

            if (appointments.Count < 3) return null;

            var intervals = new List<TimeSpan>();
            for (int i = 1; i < appointments.Count; i++)
            {
                intervals.Add(appointments[i].Vrijeme - appointments[i - 1].Vrijeme);
            }

            var averageIntervalTicks = (long)intervals.Average(i => i.Ticks);
            var averageInterval = new TimeSpan(averageIntervalTicks);

            // Round to common intervals
            if (averageInterval.TotalDays >= 27 && averageInterval.TotalDays <= 33)
                return TimeSpan.FromDays(30);
            else if (averageInterval.TotalDays >= 19 && averageInterval.TotalDays <= 25)
                return TimeSpan.FromDays(21);
            else if (averageInterval.TotalDays >= 12 && averageInterval.TotalDays <= 18)
                return TimeSpan.FromDays(14);
            else if (averageInterval.TotalDays >= 5 && averageInterval.TotalDays <= 9)
                return TimeSpan.FromDays(7);

            return null;
        }

        private async Task<DateTime?> GetLastCompletedAppointmentDate(int klijentId)
        {
            return await _context.Termin
                .Where(t => t.KlijentId == klijentId && t.Vrijeme < DateTime.Now)
                .OrderByDescending(t => t.Vrijeme)
                .Select(t => t.Vrijeme)
                .FirstOrDefaultAsync();
        }

        private string GetRecommendationReason(float score, Model.Korisnik barber, TimeSpan? detectedInterval, DateTime? lastAppointmentDate)
        {
            string baseReason = score > 0.9
                ? $"Visoko preporučeno na osnovu vaših prethodnih rezervacija kod {barber.Ime}"
                : score > 0.8
                    ? $"Popularan termin kod {barber.Ime} koji odgovara vašim navikama"
                    : "Dobar izbor prema vašoj historiji rezervacija";

            if (detectedInterval.HasValue && lastAppointmentDate.HasValue)
            {
                var days = detectedInterval.Value.TotalDays;
                baseReason += $" (preporuka za vaš redovni {days}-dnevni ritam šišanja)";
            }
            else if (lastAppointmentDate.HasValue)
            {
                var daysSince = (DateTime.Now.Date - lastAppointmentDate.Value.Date).Days;
                baseReason += $" (prošlo je {daysSince} dana od poslednjeg šišanja)";
            }

            return baseReason;
        }


        public async Task<Model.PredvidjanjeZauzetosti> PredictBusyness(int korisnikId, DateTime datum, List<Model.Termin> historija)
        {
            // 1. Prepare training data with improved logic
            var trainingData = await PrepareBusynessTrainingData(korisnikId);

            // Check if we have enough data to train
            if (trainingData.GetRowCount() == 0)
            {
                return GenerateDefaultPrediction(korisnikId, datum);
            }

            // 2. Enhanced pipeline with more features
            var pipeline = _mlContext.Transforms.Concatenate("Features",
                    nameof(BusynessData.DayOfWeek),
                    nameof(BusynessData.TimeSlot),
                    nameof(BusynessData.Month),
                    nameof(BusynessData.IsHoliday))
                .Append(_mlContext.Regression.Trainers.Sdca(
                    labelColumnName: nameof(BusynessData.BusyPercentage),
                    maximumNumberOfIterations: 100));

            // 3. Train model with validation
            var model = pipeline.Fit(trainingData);

            // 4. Make predictions for each hour
            var predictionEngine = _mlContext.Model.CreatePredictionEngine<BusynessData, BusynessPrediction>(model);
            var busynessPerHour = new Dictionary<string, double>();
            var recommendedSlots = new List<string>();

            for (int hour = 9; hour <= 17; hour++)
            {
                var input = new BusynessData
                {
                    BarberId = korisnikId,
                    DayOfWeek = (float)datum.DayOfWeek,
                    TimeSlot = hour,
                    Month = datum.Month,
                    IsHoliday = IsHoliday(datum) ? 1 : 0,
                    BusyPercentage = 0 // Will be predicted
                };

                var prediction = predictionEngine.Predict(input);

                // Apply smoothing and ensure reasonable values
                var busyPercentage = Math.Min(1, Math.Max(0, prediction.BusyPercentage * 1.2));

                busynessPerHour.Add($"{hour}:00", busyPercentage);

                if (busyPercentage < 0.7)
                {
                    recommendedSlots.Add($"{hour}:00");
                }
            }

            return new Model.PredvidjanjeZauzetosti
            {
                KorisnikId = korisnikId,
                Datum = datum,
                ZauzetostPoSatima = busynessPerHour.Select(x => new Model.ZauzetostPoSatu
                {
                    Sat = x.Key,
                    Vrijednost = x.Value
                }).ToList(),
                UkupnaZauzetost = busynessPerHour.Values.Average(),
                PreporuceniTermini = recommendedSlots,
                IsDefaultPrediction = false
            };
        }

        private async Task<IDataView> PrepareRecommendationTrainingData(int klijentId)
        {
            // Dohvaćamo sve historijske rezervacije za klijenta
            var reservations = await _context.Rezervacija
                .Include(r => r.Termins)
                .Where(r => r.KlijentId == klijentId)
                .ToListAsync();

            var trainingData = new List<AppointmentRecommendationData>();

            foreach (var reservation in reservations)
            {
                foreach (var termin in reservation.Termins)
                {
                    trainingData.Add(new AppointmentRecommendationData
                    {
                        ClientId = klijentId,
                        BarberId = termin.KorisnikID,
                        ServiceId = reservation.UslugaId,
                        DayOfWeek = (float)termin.Vrijeme.DayOfWeek,
                        TimeOfDay = termin.Vrijeme.Hour,
                        Label = 1 // Prihvaćen termin
                    });

                    // Dodajemo i negativne primjere (neodabrane termine)
                    // Ovo je pojednostavljeno - u praksi bi trebali pametnije generisati negativne primjere
                    if (termin.Vrijeme.DayOfWeek != DayOfWeek.Monday)
                    {
                        trainingData.Add(new AppointmentRecommendationData
                        {
                            ClientId = klijentId,
                            BarberId = termin.KorisnikID,
                            ServiceId = reservation.UslugaId,
                            DayOfWeek = (float)DayOfWeek.Monday,
                            TimeOfDay = termin.Vrijeme.Hour,
                            Label = 0 // Neodabran termin
                        });
                    }
                }
            }

            return _mlContext.Data.LoadFromEnumerable(trainingData);
        }

        private async Task<IDataView> PrepareBusynessTrainingData(int korisnikId)
        {
            // Get appointments from last 6 months for better accuracy
            var sixMonthsAgo = DateTime.Now.AddMonths(-6);

            var appointments = await _context.Termin
                .Where(t => t.KorisnikID == korisnikId &&
                           t.Vrijeme >= sixMonthsAgo &&
                           t.Vrijeme < DateTime.Now)
                .ToListAsync();

            // If no data, return empty set (handled by caller)
            if (!appointments.Any())
            {
                return _mlContext.Data.LoadFromEnumerable(new List<BusynessData>());
            }

            // Calculate busyness more precisely
            var trainingData = new List<BusynessData>();

            // Group by day and hour
            var dailyGroups = appointments
                .GroupBy(t => new { t.Vrijeme.Date, t.Vrijeme.Hour })
                .Select(g => new {
                    Date = g.Key.Date,
                    Hour = g.Key.Hour,
                    Count = g.Count(),
                    // Assume barber can handle 2 appointments per hour
                    BusyPercentage = Math.Min(1, g.Count() / 2.0)
                });

            foreach (var item in dailyGroups)
            {
                trainingData.Add(new BusynessData
                {
                    BarberId = korisnikId,
                    DayOfWeek = (float)item.Date.DayOfWeek,
                    TimeSlot = item.Hour,
                    Month = item.Date.Month,
                    IsHoliday = IsHoliday(item.Date) ? 1 : 0,
                    
                    BusyPercentage = (float)item.BusyPercentage
                });
            }

            return _mlContext.Data.LoadFromEnumerable(trainingData);
        }
        private Model.PredvidjanjeZauzetosti GenerateDefaultPrediction(int korisnikId, DateTime datum)
        {
            // Default pattern when no historical data exists
            var busynessPerHour = new Dictionary<string, double>();
            var recommendedSlots = new List<string>();

            // Weekday pattern
            if (datum.DayOfWeek != DayOfWeek.Saturday && datum.DayOfWeek != DayOfWeek.Sunday)
            {
                for (int hour = 9; hour <= 17; hour++)
                {
                    var busyness = (hour >= 10 && hour <= 12) || (hour >= 15 && hour <= 17) ? 0.6 : 0.3;
                    busynessPerHour.Add($"{hour}:00", busyness);

                    if (busyness < 0.7) recommendedSlots.Add($"{hour}:00");
                }
            }
            else // Weekend pattern
            {
                for (int hour = 10; hour <= 15; hour++)
                {
                    busynessPerHour.Add($"{hour}:00", 0.8);
                    if (hour == 12) recommendedSlots.Add($"{hour}:00");
                }
            }

            return new Model.PredvidjanjeZauzetosti
            {
                KorisnikId = korisnikId,
                Datum = datum,
                ZauzetostPoSatima = busynessPerHour.Select(x => new Model.ZauzetostPoSatu
                {
                    Sat = x.Key,
                    Vrijednost = x.Value
                }).ToList(),
                UkupnaZauzetost = busynessPerHour.Values.Average(),
                PreporuceniTermini = recommendedSlots,
                IsDefaultPrediction = true
            };
        }
        private bool IsHoliday(DateTime date)
        {
            // Ovo je pojednostavljena implementacija
            // U praksi bi trebali koristiti neki servis za praznike
            return date.DayOfWeek == DayOfWeek.Saturday ||
                   date.DayOfWeek == DayOfWeek.Sunday ||
                   (date.Month == 1 && date.Day == 1) || // Nova godina
                   (date.Month == 5 && date.Day == 1);   // Praznik rada
        }


        // Modeli podataka za ML.NET
        private class AppointmentRecommendationData
        {
            public float ClientId { get; set; }
            public float BarberId { get; set; }
            public float ServiceId { get; set; }
            public float DayOfWeek { get; set; }
            public float TimeOfDay { get; set; }
            public float Label { get; set; }
        }

        private class AppointmentPrediction
        {
            public float Score { get; set; }
        }

        private class BusynessData
        {
            public float BarberId { get; set; }
            public float DayOfWeek { get; set; }
            public float TimeSlot { get; set; }
            public float Month { get; set; }
            public float IsHoliday { get; set; }
            public float BusyPercentage { get; set; }
        }

        private class BusynessPrediction
        {
            [ColumnName("Score")]
            public float BusyPercentage { get; set; }
        }
    }
}