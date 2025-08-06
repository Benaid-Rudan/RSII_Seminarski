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
            // 1. Priprema podataka za treniranje
            var trainingData = await PrepareRecommendationTrainingData(klijentId);

            // 2. Definišemo pipeline za preporuke
            var pipeline = _mlContext.Transforms.Conversion.MapValueToKey(
                    outputColumnName: "Label",
                    inputColumnName: nameof(AppointmentRecommendationData.Label))
                .Append(_mlContext.Transforms.Concatenate("Features",
                    nameof(AppointmentRecommendationData.ClientId),
                    nameof(AppointmentRecommendationData.BarberId),
                    nameof(AppointmentRecommendationData.ServiceId),
                    nameof(AppointmentRecommendationData.DayOfWeek),
                    nameof(AppointmentRecommendationData.TimeOfDay))
                .Append(_mlContext.Recommendation().Trainers.MatrixFactorization(
                    new MatrixFactorizationTrainer.Options
                    {
                        MatrixColumnIndexColumnName = "Features",
                        MatrixRowIndexColumnName = "Label",
                        LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                        Alpha = 0.01,
                        Lambda = 0.025,
                        NumberOfIterations = 100
                    })));

            // 3. Treniramo model
            var model = pipeline.Fit(trainingData);

            // 4. Generišemo preporuke za sve frizere
            var allBarbers = await _context.Korisnik
                .Where(k => k.KorisnikId == 2) // Pretpostavka da je tip 2 za frizere
                .ToListAsync();

            var recommendations = new List<Model.PreporukaTermina>();
            var predictionEngine = _mlContext.Model.CreatePredictionEngine<AppointmentRecommendationData, AppointmentPrediction>(model);

            foreach (var barber in allBarbers)
            {
                // Mapiraj Database.Korisnik u Model.Korisnik
                var barberModel = _mapper.Map<Model.Korisnik>(barber);

                // Generišemo preporuke za narednih 7 dana
                for (int daysFromNow = 1; daysFromNow <= 7; daysFromNow++)
                {
                    var date = DateTime.Now.AddDays(daysFromNow);
                    var dayOfWeek = (float)date.DayOfWeek;

                    // Provjeravamo radno vrijeme (9-17h)
                    for (int hour = 9; hour <= 17; hour++)
                    {
                        var input = new AppointmentRecommendationData
                        {
                            ClientId = klijentId,
                            BarberId = barber.KorisnikId,
                            ServiceId = uslugaId,
                            DayOfWeek = dayOfWeek,
                            TimeOfDay = hour,
                            Label = 1 // Neutralna vrijednost za predikciju
                        };

                        var prediction = predictionEngine.Predict(input);

                        // Dodajemo samo preporuke sa visokim score-om
                        if (prediction.Score > 0.7)
                        {
                            recommendations.Add(new Model.PreporukaTermina
                            {
                                KlijentId = klijentId,
                                KorisnikId = barber.KorisnikId,
                                UslugaId = uslugaId,
                                PreporuceniTermin = new DateTime(date.Year, date.Month, date.Day, hour, 0, 0),
                                SkorPovjerenja = prediction.Score,
                                RazlogPreporuke = GetRecommendationReason(prediction.Score, barberModel),
                                IsAccepted = false
                            });
                        }
                    }
                }
            }

            // Sortiramo preporuke po score-u
            return recommendations.OrderByDescending(r => r.SkorPovjerenja).ToList();
        }

        public async Task<Model.PredvidjanjeZauzetosti> PredictBusyness(int korisnikId, DateTime datum, List<Model.Termin> historija)
        {
            // 1. Priprema podataka za treniranje
            var trainingData = await PrepareBusynessTrainingData(korisnikId);

            // 2. Definišemo pipeline za predviđanje zauzetosti
            var pipeline = _mlContext.Transforms.Concatenate("Features",
                    nameof(BusynessData.DayOfWeek),
                    nameof(BusynessData.TimeSlot),
                    nameof(BusynessData.Month),
                    nameof(BusynessData.IsHoliday))
                .Append(_mlContext.Regression.Trainers.Sdca());

            // 3. Treniramo model
            var model = pipeline.Fit(trainingData);

            // 4. Pravimo predikcije za traženi datum
            var predictionEngine = _mlContext.Model.CreatePredictionEngine<BusynessData, BusynessPrediction>(model);
            var busynessPerHour = new Dictionary<string, double>();
            var recommendedSlots = new List<string>();

            // Provjeravamo radno vrijeme (9-17h)
            for (int hour = 9; hour <= 17; hour++)
            {
                var input = new BusynessData
                {
                    BarberId = korisnikId,
                    DayOfWeek = (float)datum.DayOfWeek,
                    TimeSlot = hour,
                    Month = datum.Month,
                    IsHoliday = IsHoliday(datum) ? 1 : 0,
                    BusyPercentage = 0 // Ovo će biti predviđeno
                };

                var prediction = predictionEngine.Predict(input);
                var busyPercentage = Math.Min(1, Math.Max(0, prediction.BusyPercentage)); // Osiguravamo vrijednost između 0 i 1
                busynessPerHour.Add(hour.ToString(), busyPercentage);

                // Preporučujemo termine sa zauzetosti manjom od 70%
                if (busyPercentage < 0.7)
                {
                    recommendedSlots.Add($"{hour}:00");
                }
            }

            return new Model.PredvidjanjeZauzetosti
            {
                KorisnikId = korisnikId,
                Datum = datum,
                ZauzetostPoSatima = (ICollection<Model.ZauzetostPoSatu>)busynessPerHour,
                UkupnaZauzetost = busynessPerHour.Values.Average(),
                PreporuceniTermini = recommendedSlots
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
            // Dohvaćamo sve historijske termine za frizera
            var appointments = await _context.Termin
                .Where(t => t.KorisnikID == korisnikId && t.Vrijeme < DateTime.Now)
                .ToListAsync();

            var trainingData = new List<BusynessData>();

            // Grupišemo termine po danu i satu da izračunamo zauzetost
            var grouped = appointments
                .GroupBy(t => new { t.Vrijeme.Date, t.Vrijeme.Hour })
                .Select(g => new
                {
                    Date = g.Key.Date,
                    Hour = g.Key.Hour,
                    Count = g.Count(),
                    // Pretpostavka da frizer može imati max 1 termin po satu
                    BusyPercentage = Math.Min(1, g.Count())
                });

            foreach (var item in grouped)
            {
                trainingData.Add(new BusynessData
                {
                    BarberId = korisnikId,
                    DayOfWeek = (float)item.Date.DayOfWeek,
                    TimeSlot = item.Hour,
                    Month = item.Date.Month,
                    IsHoliday = IsHoliday(item.Date) ? 1 : 0,
                    BusyPercentage = item.BusyPercentage
                });
            }

            return _mlContext.Data.LoadFromEnumerable(trainingData);
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

        private string GetRecommendationReason(float score, Model.Korisnik barber)
        {
            if (score > 0.9)
                return $"Visoko preporučeno na osnovu vaših prethodnih rezervacija kod {barber.Ime}";
            if (score > 0.8)
                return $"Popularan termin kod {barber.Ime} koji odgovara vašim navikama";
            return $"Dobar izbor prema vašoj historiji rezervacija";
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