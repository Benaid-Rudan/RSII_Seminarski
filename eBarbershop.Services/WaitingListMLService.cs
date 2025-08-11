// eBarbershop.Services/WaitingListMLService.cs
using AutoMapper;
using eBarbershop.Services.Database;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.EntityFrameworkCore;
namespace eBarbershop.Services
{
    public interface IWaitingListMLService
    {
        Task<int> CalculatePriorityScore(int klijentId, int frizerId, int uslugaId, DateTime zeljeniDatum);
        Task<List<Model.ListaCekanja>> GetOptimalNotificationOrder(List<Model.ListaCekanja> waitingList);
        Task<double> PredictAcceptanceProbability(int klijentId, int terminId);
        Task<List<int>> FindBestCandidatesForSlot(int terminId, List<int> waitingListIds);
        Task RetrainModel();
    }

    public class WaitingListMLService : IWaitingListMLService
    {
        private readonly EBarbershop1Context _context;
        private readonly IMapper _mapper;
        private readonly MLContext _mlContext;

        public WaitingListMLService(EBarbershop1Context context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
            _mlContext = new MLContext(seed: 1);
        }

        public async Task<int> CalculatePriorityScore(int klijentId, int frizerId, int uslugaId, DateTime zeljeniDatum)
        {
            var basePriority = (zeljeniDatum - DateTime.Now).TotalDays; // Pozitivno ako je datum u budućnosti
            basePriority = Math.Max(0, basePriority); // Nemoj negativne vrijednosti


            // ML faktor baziran na povijesti klijenta
            var clientHistory = await GetClientHistoryScore(klijentId, frizerId);
            var loyaltyBonus = await GetClientLoyaltyBonus(klijentId);
            var barberPreference = await GetBarberPreferenceScore(klijentId, frizerId);
            var servicePopularity = await GetServicePopularityScore(uslugaId);
            
            // Kombinacija faktora
            var mlScore = (clientHistory * 0.3) + (loyaltyBonus * 0.25) + 
                         (barberPreference * 0.25) + (servicePopularity * 0.2);
            
            return (int)Math.Max(1, Math.Min(100, basePriority + (mlScore * 20)));
        }

        public async Task<List<Model.ListaCekanja>> GetOptimalNotificationOrder(List<Model.ListaCekanja> waitingList)
        {
            // Treniramo model za optimalni redoslijed notifikacija
            var trainingData = await PrepareNotificationTrainingData();
            var pipeline = BuildNotificationPipeline();
            var model = _notificationModel ?? pipeline.Fit(trainingData);


            var predictionEngine = _mlContext.Model.CreatePredictionEngine<WaitingListMLData, WaitingListPrediction>(model);
            
            // Računamo ML score za svaku stavku u listi čekanja
            foreach (var item in waitingList)
            {
                var mlData = await CreateMLDataFromWaitingListItem(item);
                var prediction = predictionEngine.Predict(mlData);
                item.MLSkor = prediction.AcceptanceProbability;
            }
            
            // Sortiramo po kombinaciji prioriteta i ML score-a
            return waitingList
                .OrderByDescending(w => (w.Prioritet * 0.6) + (w.MLSkor * 0.4))
                .ToList();
        }

        public async Task<double> PredictAcceptanceProbability(int klijentId, int terminId)
        {
            var trainingData = await PrepareAcceptanceTrainingData();
            var pipeline = BuildAcceptancePipeline();
            var model = pipeline.Fit(trainingData);
            
            var predictionEngine = _mlContext.Model.CreatePredictionEngine<AcceptanceMLData, AcceptancePrediction>(model);
            
            var termin = await _context.Termin.Include(t => t.Rezervacija)
                .ThenInclude(r => r.Usluga)
                .FirstOrDefaultAsync(t => t.TerminId == terminId);
                
            if (termin == null) return 0.0;
            
            var mlData = await CreateAcceptanceMLData(klijentId, termin);
            var prediction = predictionEngine.Predict(mlData);
            
            return Math.Max(0, Math.Min(1, prediction.Probability));
        }

        public async Task<List<int>> FindBestCandidatesForSlot(int terminId, List<int> waitingListIds)
        {
            var candidates = await _context.ListaCekanja
                .Where(w => waitingListIds.Contains(w.ListaCekanjaId) && w.Status == 1)
                .Include(w => w.Klijent)
                .Include(w => w.Usluga)
                .ToListAsync();
            
            var scoredCandidates = new List<(int Id, double Score)>();
            
            foreach (var candidate in candidates)
            {
                var acceptanceProbability = await PredictAcceptanceProbability(candidate.KlijentId, terminId);
                var timeFlexibility = CalculateTimeFlexibility(candidate);
                var waitingTime = (DateTime.Now - candidate.DatumPrijave).TotalDays;
                
                // Kombinacija faktora za konačni score
                var finalScore = (acceptanceProbability * 0.4) + 
                               (timeFlexibility * 0.3) + 
                               (waitingTime / 30.0 * 0.3); // Normalizacija čekanja na 30 dana
                
                scoredCandidates.Add((candidate.ListaCekanjaId, finalScore));
            }
            
            return scoredCandidates
                .OrderByDescending(c => c.Score)
                .Select(c => c.Id)
                .ToList();
        }
        private ITransformer _notificationModel;
        private const string NotificationModelPath = "waitinglist_notification_model.zip";

        public async Task RetrainModel()
        {
            var historicalData = await PrepareHistoricalTrainingData();

            if (historicalData.GetRowCount() > 100)
            {
                var pipeline = BuildNotificationPipeline();
                var model = pipeline.Fit(historicalData);

                _notificationModel = model;
                _mlContext.Model.Save(model, historicalData.Schema, NotificationModelPath);
            }
        }

        public void LoadNotificationModel()
        {
            if (File.Exists(NotificationModelPath))
            {
                DataViewSchema modelSchema;
                _notificationModel = _mlContext.Model.Load(NotificationModelPath, out modelSchema);
            }
        }

        #region Helper Methods

        private async Task<double> GetClientHistoryScore(int klijentId, int frizerId)
        {
            var reservations = await _context.Rezervacija
                .Where(r => r.KlijentId == klijentId && r.KorisnikId == frizerId)
                .CountAsync();
            
            return Math.Min(1.0, reservations / 10.0); // Max score za 10+ rezervacija
        }

        private async Task<double> GetClientLoyaltyBonus(int klijentId)
        {
            var totalReservations = await _context.Rezervacija
                .Where(r => r.KlijentId == klijentId)
                .CountAsync();
            
            var avgRating = await _context.Recenzija
                .Where(r => r.KorisnikId == klijentId)
                .AverageAsync(r => (double?)r.Ocjena) ?? 3.0;
            
            return (Math.Min(1.0, totalReservations / 20.0)) * (avgRating / 5.0);
        }

        private async Task<double> GetBarberPreferenceScore(int klijentId, int frizerId)
        {
            var totalWithBarber = await _context.Rezervacija
                .Where(r => r.KlijentId == klijentId && r.KorisnikId == frizerId)
                .CountAsync();
            
            var totalReservations = await _context.Rezervacija
                .Where(r => r.KlijentId == klijentId)
                .CountAsync();
            
            return totalReservations > 0 ? (double)totalWithBarber / totalReservations : 0.0;
        }

        private async Task<double> GetServicePopularityScore(int uslugaId)
        {
            var serviceReservations = await _context.Rezervacija
                .Where(r => r.UslugaId == uslugaId)
                .CountAsync();
            
            var totalReservations = await _context.Rezervacija.CountAsync();
            
            return totalReservations > 0 ? Math.Min(1.0, (double)serviceReservations / totalReservations * 10) : 0.5;
        }

        private double CalculateTimeFlexibility(Database.ListaCekanja candidate)
        {
            // Ako klijent nije specificirao točno vrijeme, fleksibilniji je
            return candidate.ZeljenoVrijeme.HasValue ? 0.3 : 1.0;
        }

        private async Task<IDataView> PrepareNotificationTrainingData()
        {
            var historicalNotifications = await _context.NotifikacijaListeCekanja
                .Include(n => n.ListaCekanja)
                .ThenInclude(l => l.Klijent)
                .Where(n => n.Odgovoreno)
                .Select(n => new WaitingListMLData
                {
                    KlijentId = n.ListaCekanja.KlijentId,
                    FrizerId = n.ListaCekanja.FrizerId,
                    UslugaId = n.ListaCekanja.UslugaId,
                    DanUNedelji = (float)n.DatumNotifikacije.DayOfWeek,
                    SatUDanu = n.DatumNotifikacije.Hour,
                    DaniDoZeljenogTermina = (float)(n.ListaCekanja.ZeljeniDatum - n.DatumNotifikacije).TotalDays,
                    Label = n.Prihvaceno
                })
                .ToListAsync();

            return _mlContext.Data.LoadFromEnumerable(historicalNotifications);
        }

        private IEstimator<ITransformer> BuildNotificationPipeline()
        {
            return _mlContext.Transforms.Concatenate("Features",
                    nameof(WaitingListMLData.KlijentId),
                    nameof(WaitingListMLData.FrizerId),
                    nameof(WaitingListMLData.UslugaId),
                    nameof(WaitingListMLData.DanUNedelji),
                    nameof(WaitingListMLData.SatUDanu),
                    nameof(WaitingListMLData.DaniDoZeljenogTermina))
                .Append(_mlContext.Transforms.NormalizeMinMax("Features"))
                .Append(_mlContext.BinaryClassification.Trainers.SdcaLogisticRegression());
        }

        private IEstimator<ITransformer> BuildAcceptancePipeline()
        {
            return _mlContext.Transforms.Concatenate("Features",
                    nameof(AcceptanceMLData.KlijentId),
                    nameof(AcceptanceMLData.FrizerId),
                    nameof(AcceptanceMLData.UslugaId),
                    nameof(AcceptanceMLData.DanUNedelji),
                    nameof(AcceptanceMLData.SatUDanu),
                    nameof(AcceptanceMLData.BrojPrethodnihRezervacija),
                    nameof(AcceptanceMLData.ProsjekOcjena))
                .Append(_mlContext.Transforms.NormalizeMinMax("Features"))
                .Append(_mlContext.BinaryClassification.Trainers.AveragedPerceptron(
                    new Microsoft.ML.Trainers.AveragedPerceptronTrainer.Options
                    {
                        LearningRate = 0.1f,
                        NumberOfIterations = 100,
                        FeatureColumnName = "Features"
                    }));
        }

        private IEstimator<ITransformer> BuildComprehensivePipeline()
        {
            return _mlContext.Transforms.Concatenate("Features",
                    nameof(WaitingListMLData.KlijentId),
                    nameof(WaitingListMLData.FrizerId),
                    nameof(WaitingListMLData.UslugaId),
                    nameof(WaitingListMLData.DanUNedelji),
                    nameof(WaitingListMLData.SatUDanu),
                    nameof(WaitingListMLData.TrenutnaZauzetost),
                    nameof(WaitingListMLData.BrojPrethodnihRezervacija),
                    nameof(WaitingListMLData.ProsjekOcjena),
                    nameof(WaitingListMLData.DaniDoZeljenogTermina),
                    nameof(WaitingListMLData.SezonalnostFaktor))
                .Append(_mlContext.Regression.Trainers.Sdca());
        }

        private async Task<WaitingListMLData> CreateMLDataFromWaitingListItem(Model.ListaCekanja item)
        {
            return new WaitingListMLData
            {
                KlijentId = item.KlijentId,
                FrizerId = item.FrizerId,
                UslugaId = item.UslugaId,
                DanUNedelji = (float)item.ZeljeniDatum.DayOfWeek,
                SatUDanu = item.ZeljenoVrijeme.HasValue ? (float)item.ZeljenoVrijeme.Value.Hours : 12f,
                DaniDoZeljenogTermina = (float)(item.ZeljeniDatum - DateTime.Now).TotalDays,
                BrojPrethodnihRezervacija = await _context.Rezervacija
                    .Where(r => r.KlijentId == item.KlijentId)
                    .CountAsync(),
                ProsjekOcjena = (float)(await _context.Recenzija
                    .Where(r => r.KorisnikId == item.KlijentId)
                    .AverageAsync(r => (double?)r.Ocjena) ?? 3.0),
                Label = true // Dummy vrijednost za prediction
            };
        }

        private async Task<AcceptanceMLData> CreateAcceptanceMLData(int klijentId, Database.Termin termin)
        {
            return new AcceptanceMLData
            {
                KlijentId = klijentId,
                FrizerId = termin.KorisnikID,
                UslugaId = termin.Rezervacija.UslugaId,
                DanUNedelji = (float)termin.Vrijeme.DayOfWeek,
                SatUDanu = termin.Vrijeme.Hour,
                BrojPrethodnihRezervacija = await _context.Rezervacija
                    .Where(r => r.KlijentId == klijentId)
                    .CountAsync(),
                ProsjekOcjena = (float)(await _context.Recenzija
                    .Where(r => r.KorisnikId == klijentId)
                    .AverageAsync(r => (double?)r.Ocjena) ?? 3.0),
                Label = true
            };
        }

        private async Task<IDataView> PrepareAcceptanceTrainingData()
        {
            var data = await _context.NotifikacijaListeCekanja
                .Include(n => n.ListaCekanja)
                .Include(n => n.Termin)
                .ThenInclude(t => t.Rezervacija)
                .Where(n => n.Odgovoreno)
                .Select(n => new AcceptanceMLData
                {
                    KlijentId = n.ListaCekanja.KlijentId,
                    FrizerId = n.ListaCekanja.FrizerId,
                    UslugaId = n.Termin.Rezervacija.UslugaId,
                    DanUNedelji = (float)n.Termin.Vrijeme.DayOfWeek,
                    SatUDanu = n.Termin.Vrijeme.Hour,
                    Label = n.Prihvaceno
                })
                .ToListAsync();

            return _mlContext.Data.LoadFromEnumerable(data);
        }

        private async Task<IDataView> PrepareHistoricalTrainingData()
        {
            var data = await _context.ListaCekanja
                .Where(l => l.Status != 1) // Završene liste čekanja
                .Select(l => new WaitingListMLData
                {
                    KlijentId = l.KlijentId,
                    FrizerId = l.FrizerId,
                    UslugaId = l.UslugaId,
                    DanUNedelji = (float)l.ZeljeniDatum.DayOfWeek,
                    SatUDanu = l.ZeljenoVrijeme.HasValue ? (float)l.ZeljenoVrijeme.Value.Hours : 12f,
                    DaniDoZeljenogTermina = (float)(l.ZeljeniDatum - l.DatumPrijave).TotalDays,
                    Label = l.Status == 3 ? true : false
                })
                .ToListAsync();

            if (data.Count == 0)
            {
                // Dummy podatak za testiranje kada nema podataka u bazi
                data = new List<WaitingListMLData>
        {
            new WaitingListMLData
            {
                KlijentId = 3,
                FrizerId = 2,
                UslugaId = 1,
                DanUNedelji = 1,
                SatUDanu = 12,
                DaniDoZeljenogTermina = 5,
                Label = true
            }
        };
            }

            return _mlContext.Data.LoadFromEnumerable(data);
        }
        private class WaitingListPrediction
        {
            [ColumnName("Probability")]
            public float AcceptanceProbability { get; set; }
        }

        private class WaitingListMLData
        {
            public float KlijentId { get; set; }
            public float FrizerId { get; set; }
            public float UslugaId { get; set; }
            public float DanUNedelji { get; set; }
            public float SatUDanu { get; set; }
            public float TrenutnaZauzetost { get; set; }
            public float BrojPrethodnihRezervacija { get; set; }
            public float ProsjekOcjena { get; set; }
            public float DaniDoZeljenogTermina { get; set; }
            public float SezonalnostFaktor { get; set; }
            public bool Label { get; set; }  // <- promijenjeno iz float u bool
        }

        private class AcceptanceMLData
        {
            public float KlijentId { get; set; }
            public float FrizerId { get; set; }
            public float UslugaId { get; set; }
            public float DanUNedelji { get; set; }
            public float SatUDanu { get; set; }
            public float BrojPrethodnihRezervacija { get; set; }
            public float ProsjekOcjena { get; set; }
            public bool Label { get; set; }  // <- promijenjeno iz float u bool
        }


        private class AcceptancePrediction
        {
            [ColumnName("Probability")]
            public float Probability { get; set; }
        }

        #endregion
    }
}