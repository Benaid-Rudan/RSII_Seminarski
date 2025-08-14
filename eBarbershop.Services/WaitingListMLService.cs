// eBarbershop.Services/WaitingListMLService.cs
using AutoMapper;
using eBarbershop.Services.Database;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

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
        private readonly ILogger<WaitingListMLService> _logger;

        public WaitingListMLService(EBarbershop1Context context, IMapper mapper, ILogger<WaitingListMLService> logger)
        {
            _context = context;
            _mapper = mapper;
            _mlContext = new MLContext(seed: 1);
            _logger = logger;
        }

        public async Task<int> CalculatePriorityScore(int klijentId, int frizerId, int uslugaId, DateTime zeljeniDatum)
        {
            try
            {
                var basePriority = Math.Max(1, (zeljeniDatum - DateTime.Now).TotalDays);

                // ML faktori s graceful degradation
                var clientHistory = await GetClientHistoryScore(klijentId, frizerId);
                var loyaltyBonus = await GetClientLoyaltyBonus(klijentId);
                var barberPreference = await GetBarberPreferenceScore(klijentId, frizerId);
                var servicePopularity = await GetServicePopularityScore(uslugaId);

                // Kombinacija faktora
                var mlScore = (clientHistory * 0.3) + (loyaltyBonus * 0.25) +
                             (barberPreference * 0.25) + (servicePopularity * 0.2);

                return (int)Math.Max(1, Math.Min(100, basePriority + (mlScore * 20)));
            }
            catch (Exception ex)
            {
                _logger.LogWarning($"Error calculating priority score: {ex.Message}");
                // Fallback to simple priority based on date
                return (int)Math.Max(1, Math.Min(100, (zeljeniDatum - DateTime.Now).TotalDays + 50));
            }
        }

        public async Task<List<Model.ListaCekanja>> GetOptimalNotificationOrder(List<Model.ListaCekanja> waitingList)
        {
            try
            {
                // Provjeri ima li dovoljno podataka za ML
                var hasEnoughData = await HasEnoughTrainingData();

                if (!hasEnoughData)
                {
                    _logger.LogInformation("Not enough training data, using fallback ordering");
                    return GetFallbackNotificationOrder(waitingList);
                }

                // Treniramo model za optimalni redoslijed notifikacija
                var trainingData = await PrepareNotificationTrainingData();
                var pipeline = BuildNotificationPipeline();
                var model = pipeline.Fit(trainingData);

                var predictionEngine = _mlContext.Model.CreatePredictionEngine<WaitingListMLData, WaitingListPrediction>(model);

                // Računamo ML score za svaku stavku u listi čekanja
                foreach (var item in waitingList)
                {
                    try
                    {
                        var mlData = await CreateMLDataFromWaitingListItem(item);
                        var prediction = predictionEngine.Predict(mlData);
                        item.MLSkor = Math.Max(0, Math.Min(1, prediction.AcceptanceProbability));
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning($"Error predicting for item {item.ListaCekanjaId}: {ex.Message}");
                        item.MLSkor = 0.5; // Default value
                    }
                }

                // Sortiramo po kombinaciji prioriteta i ML score-a
                return waitingList
                    .OrderByDescending(w => (w.Prioritet * 0.6) + (w.MLSkor * 100 * 0.4))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error in ML notification ordering: {ex.Message}");
                return GetFallbackNotificationOrder(waitingList);
            }
        }

        public async Task<double> PredictAcceptanceProbability(int klijentId, int terminId)
        {
            try
            {
                var hasEnoughData = await HasEnoughAcceptanceData();

                if (!hasEnoughData)
                {
                    return GetFallbackAcceptanceProbability(klijentId, terminId);
                }

                var trainingData = await PrepareAcceptanceTrainingData();
                var pipeline = BuildAcceptancePipeline();
                var model = pipeline.Fit(trainingData);

                var predictionEngine = _mlContext.Model.CreatePredictionEngine<AcceptanceMLData, AcceptancePrediction>(model);

                var termin = await _context.Termin.Include(t => t.Rezervacija)
                    .ThenInclude(r => r.Usluga)
                    .FirstOrDefaultAsync(t => t.TerminId == terminId);

                if (termin == null) return 0.5;

                var mlData = await CreateAcceptanceMLData(klijentId, termin);
                var prediction = predictionEngine.Predict(mlData);

                return Math.Max(0, Math.Min(1, prediction.Probability));
            }
            catch (Exception ex)
            {
                _logger.LogWarning($"Error predicting acceptance probability: {ex.Message}");
                return GetFallbackAcceptanceProbability(klijentId, terminId);
            }
        }

        public async Task<List<int>> FindBestCandidatesForSlot(int terminId, List<int> waitingListIds)
        {
            try
            {
                var candidates = await _context.ListaCekanja
                    .Where(w => waitingListIds.Contains(w.ListaCekanjaId))
                    .Include(w => w.Klijent)
                    .Include(w => w.Usluga)
                    .ToListAsync();

                var scoredCandidates = new List<(int Id, double Score)>();

                foreach (var candidate in candidates)
                {
                    try
                    {
                        var acceptanceProbability = await PredictAcceptanceProbability(candidate.KlijentId, terminId);
                        var timeFlexibility = CalculateTimeFlexibility(candidate);
                        var waitingTime = (DateTime.Now - candidate.DatumPrijave).TotalDays;

                        // Kombinacija faktora za konačni score
                        var finalScore = (acceptanceProbability * 0.4) +
                                       (timeFlexibility * 0.3) +
                                       (Math.Min(waitingTime / 30.0, 1.0) * 0.3); // Normalizacija čekanja na 30 dana

                        scoredCandidates.Add((candidate.ListaCekanjaId, finalScore));
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning($"Error scoring candidate {candidate.ListaCekanjaId}: {ex.Message}");
                        // Fallback scoring
                        var waitingTime = (DateTime.Now - candidate.DatumPrijave).TotalDays;
                        var fallbackScore = Math.Min(waitingTime / 30.0, 1.0);
                        scoredCandidates.Add((candidate.ListaCekanjaId, fallbackScore));
                    }
                }

                return scoredCandidates
                    .OrderByDescending(c => c.Score)
                    .Select(c => c.Id)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error finding best candidates: {ex.Message}");
                // Return original order as fallback
                return waitingListIds;
            }
        }

        public async Task RetrainModel()
        {
            try
            {
                var historicalData = await PrepareHistoricalTrainingData();

                if (historicalData.GetRowCount() > 10) // Reduced threshold
                {
                    var pipeline = BuildNotificationPipeline();
                    var model = pipeline.Fit(historicalData);
                    _logger.LogInformation("ML model retrained successfully");
                }
                else
                {
                    _logger.LogInformation("Not enough data for retraining model");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error retraining model: {ex.Message}");
            }
        }

        #region Fallback Methods

        private List<Model.ListaCekanja> GetFallbackNotificationOrder(List<Model.ListaCekanja> waitingList)
        {
            // Simple fallback ordering when ML is not available
            return waitingList
                .OrderByDescending(w => w.Prioritet)
                .ThenBy(w => w.DatumPrijave)
                .ToList();
        }

        private double GetFallbackAcceptanceProbability(int klijentId, int terminId)
        {
            try
            {
                // Simple heuristic based on client history
                var clientReservations = _context.Rezervacija
                    .Where(r => r.KlijentId == klijentId)
                    .Count();

                var avgRating = _context.Recenzija
                    .Where(r => r.KorisnikId == klijentId)
                    .Average(r => (double?)r.Ocjena) ?? 4.0;

                // Higher probability for clients with more reservations and good ratings
                var probability = 0.3 + (Math.Min(clientReservations, 10) / 10.0 * 0.4) + (avgRating / 5.0 * 0.3);
                return Math.Max(0.1, Math.Min(0.9, probability));
            }
            catch
            {
                return 0.5; // Default probability
            }
        }

        private async Task<bool> HasEnoughTrainingData()
        {
            try
            {
                var count = await _context.NotifikacijaListeCekanja
                    .Include(n => n.ListaCekanja)
                    .Where(n => n.Odgovoreno)
                    .CountAsync();

                return count >= 10; // Minimum threshold
            }
            catch
            {
                return false;
            }
        }

        private async Task<bool> HasEnoughAcceptanceData()
        {
            try
            {
                var count = await _context.NotifikacijaListeCekanja
                    .Where(n => n.Odgovoreno)
                    .CountAsync();

                return count >= 5; // Lower threshold for acceptance data
            }
            catch
            {
                return false;
            }
        }

        #endregion

        #region Helper Methods

        private async Task<double> GetClientHistoryScore(int klijentId, int frizerId)
        {
            try
            {
                var reservations = await _context.Rezervacija
                    .Where(r => r.KlijentId == klijentId && r.KorisnikId == frizerId)
                    .CountAsync();

                return Math.Min(1.0, reservations / 10.0); // Max score za 10+ rezervacija
            }
            catch
            {
                return 0.5; // Default value
            }
        }

        private async Task<double> GetClientLoyaltyBonus(int klijentId)
        {
            try
            {
                var totalReservations = await _context.Rezervacija
                    .Where(r => r.KlijentId == klijentId)
                    .CountAsync();

                var avgRating = await _context.Recenzija
                    .Where(r => r.KorisnikId == klijentId)
                    .AverageAsync(r => (double?)r.Ocjena) ?? 4.0;

                return (Math.Min(1.0, totalReservations / 20.0)) * (avgRating / 5.0);
            }
            catch
            {
                return 0.5; // Default value
            }
        }

        private async Task<double> GetBarberPreferenceScore(int klijentId, int frizerId)
        {
            try
            {
                var totalWithBarber = await _context.Rezervacija
                    .Where(r => r.KlijentId == klijentId && r.KorisnikId == frizerId)
                    .CountAsync();

                var totalReservations = await _context.Rezervacija
                    .Where(r => r.KlijentId == klijentId)
                    .CountAsync();

                return totalReservations > 0 ? (double)totalWithBarber / totalReservations : 0.5;
            }
            catch
            {
                return 0.5; // Default value
            }
        }

        private async Task<double> GetServicePopularityScore(int uslugaId)
        {
            try
            {
                var serviceReservations = await _context.Rezervacija
                    .Where(r => r.UslugaId == uslugaId)
                    .CountAsync();

                var totalReservations = await _context.Rezervacija.CountAsync();

                return totalReservations > 0 ? Math.Min(1.0, (double)serviceReservations / totalReservations * 10) : 0.5;
            }
            catch
            {
                return 0.5; // Default value
            }
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
                    DaniDoZeljenogTermina = (float)Math.Max(0, (n.ListaCekanja.ZeljeniDatum - n.DatumNotifikacije).TotalDays),
                    BrojPrethodnihRezervacija = 0, // Will be filled
                    ProsjekOcjena = 4.0f, // Default
                    TrenutnaZauzetost = 0.5f, // Default
                    SezonalnostFaktor = 1.0f, // Default
                    Label = n.Prihvaceno
                })
                .ToListAsync();

            // If no real data, create some dummy data for testing
            if (!historicalNotifications.Any())
            {
                historicalNotifications = GenerateDummyNotificationData();
            }

            return _mlContext.Data.LoadFromEnumerable(historicalNotifications);
        }

        private List<WaitingListMLData> GenerateDummyNotificationData()
        {
            return new List<WaitingListMLData>
            {
                new WaitingListMLData { KlijentId = 3, FrizerId = 2, UslugaId = 1, DanUNedelji = 1, SatUDanu = 10, DaniDoZeljenogTermina = 5, BrojPrethodnihRezervacija = 2, ProsjekOcjena = 4.5f, TrenutnaZauzetost = 0.6f, SezonalnostFaktor = 1.0f, Label = true },
                new WaitingListMLData { KlijentId = 3, FrizerId = 2, UslugaId = 1, DanUNedelji = 2, SatUDanu = 14, DaniDoZeljenogTermina = 3, BrojPrethodnihRezervacija = 1, ProsjekOcjena = 3.8f, TrenutnaZauzetost = 0.8f, SezonalnostFaktor = 1.2f, Label = false },
                new WaitingListMLData { KlijentId = 3, FrizerId = 2, UslugaId = 1, DanUNedelji = 3, SatUDanu = 16, DaniDoZeljenogTermina = 1, BrojPrethodnihRezervacija = 5, ProsjekOcjena = 4.2f, TrenutnaZauzetost = 0.4f, SezonalnostFaktor = 0.9f, Label = true },
                new WaitingListMLData { KlijentId = 3, FrizerId = 2, UslugaId = 1, DanUNedelji = 4, SatUDanu = 12, DaniDoZeljenogTermina = 7, BrojPrethodnihRezervacija = 0, ProsjekOcjena = 4.0f, TrenutnaZauzetost = 0.7f, SezonalnostFaktor = 1.1f, Label = false },
                new WaitingListMLData { KlijentId = 3, FrizerId = 2, UslugaId = 1, DanUNedelji = 5, SatUDanu = 11, DaniDoZeljenogTermina = 2, BrojPrethodnihRezervacija = 3, ProsjekOcjena = 4.7f, TrenutnaZauzetost = 0.3f, SezonalnostFaktor = 1.0f, Label = true }
            };
        }

        private IEstimator<ITransformer> BuildNotificationPipeline()
        {
            return _mlContext.Transforms.Concatenate("Features",
                    nameof(WaitingListMLData.KlijentId),
                    nameof(WaitingListMLData.FrizerId),
                    nameof(WaitingListMLData.UslugaId),
                    nameof(WaitingListMLData.DanUNedelji),
                    nameof(WaitingListMLData.SatUDanu),
                    nameof(WaitingListMLData.DaniDoZeljenogTermina),
                    nameof(WaitingListMLData.BrojPrethodnihRezervacija),
                    nameof(WaitingListMLData.ProsjekOcjena))
                .Append(_mlContext.Transforms.NormalizeMinMax("Features"))
                .Append(_mlContext.BinaryClassification.Trainers.SdcaLogisticRegression(
                    labelColumnName: nameof(WaitingListMLData.Label),
                    featureColumnName: "Features"));
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
                .Append(_mlContext.BinaryClassification.Trainers.SdcaLogisticRegression(
                    labelColumnName: nameof(AcceptanceMLData.Label),
                    featureColumnName: "Features"));
        }

        private async Task<WaitingListMLData> CreateMLDataFromWaitingListItem(Model.ListaCekanja item)
        {
            var brojRezervacija = await _context.Rezervacija
                .Where(r => r.KlijentId == item.KlijentId)
                .CountAsync();

            var prosjekOcjena = await _context.Recenzija
                .Where(r => r.KorisnikId == item.KlijentId)
                .AverageAsync(r => (double?)r.Ocjena) ?? 4.0;

            return new WaitingListMLData
            {
                KlijentId = item.KlijentId,
                FrizerId = item.FrizerId,
                UslugaId = item.UslugaId,
                DanUNedelji = (float)item.ZeljeniDatum.DayOfWeek,
                SatUDanu = item.ZeljenoVrijeme?.Hours ?? 12,
                DaniDoZeljenogTermina = (float)Math.Max(0, (item.ZeljeniDatum - DateTime.Now).TotalDays),
                BrojPrethodnihRezervacija = brojRezervacija,
                ProsjekOcjena = (float)prosjekOcjena,
                TrenutnaZauzetost = 0.5f, // Default
                SezonalnostFaktor = 1.0f, // Default
                Label = true // Dummy vrijednost za prediction
            };
        }

        private async Task<AcceptanceMLData> CreateAcceptanceMLData(int klijentId, Database.Termin termin)
        {
            var brojRezervacija = await _context.Rezervacija
                .Where(r => r.KlijentId == klijentId)
                .CountAsync();

            var prosjekOcjena = await _context.Recenzija
                .Where(r => r.KorisnikId == klijentId)
                .AverageAsync(r => (double?)r.Ocjena) ?? 4.0;

            return new AcceptanceMLData
            {
                KlijentId = klijentId,
                FrizerId = termin.KorisnikID,
                UslugaId = termin.Rezervacija?.UslugaId ?? 1,
                DanUNedelji = (float)termin.Vrijeme.DayOfWeek,
                SatUDanu = termin.Vrijeme.Hour,
                BrojPrethodnihRezervacija = brojRezervacija,
                ProsjekOcjena = (float)prosjekOcjena,
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
                    BrojPrethodnihRezervacija = 0, // Will be calculated if needed
                    ProsjekOcjena = 4.0f, // Default
                    Label = n.Prihvaceno
                })
                .ToListAsync();

            if (!data.Any())
            {
                data = GenerateDummyAcceptanceData();
            }

            return _mlContext.Data.LoadFromEnumerable(data);
        }

        private List<AcceptanceMLData> GenerateDummyAcceptanceData()
        {
            return new List<AcceptanceMLData>
            {
                new AcceptanceMLData { KlijentId = 3, FrizerId = 2, UslugaId = 1, DanUNedelji = 1, SatUDanu = 10, BrojPrethodnihRezervacija = 2, ProsjekOcjena = 4.5f, Label = true },
                new AcceptanceMLData { KlijentId = 3, FrizerId = 2, UslugaId = 1, DanUNedelji = 2, SatUDanu = 14, BrojPrethodnihRezervacija = 1, ProsjekOcjena = 3.8f, Label = false },
                new AcceptanceMLData { KlijentId = 3, FrizerId = 2, UslugaId = 1, DanUNedelji = 3, SatUDanu = 16, BrojPrethodnihRezervacija = 5, ProsjekOcjena = 4.2f, Label = true }
            };
        }

        private async Task<IDataView> PrepareHistoricalTrainingData()
        {
            var data = await _context.ListaCekanja
                //.Where(l => l.Status != 1) // Završene liste čekanja
                .Select(l => new WaitingListMLData
                {
                    KlijentId = l.KlijentId,
                    FrizerId = l.FrizerId,
                    UslugaId = l.UslugaId,
                    DanUNedelji = (float)l.ZeljeniDatum.DayOfWeek,
                    SatUDanu = l.ZeljenoVrijeme.HasValue ? (float)l.ZeljenoVrijeme.Value.Hours : 12f,
                    DaniDoZeljenogTermina = (float)Math.Max(0, (l.ZeljeniDatum - l.DatumPrijave).TotalDays),
                    BrojPrethodnihRezervacija = 0, // Default
                    ProsjekOcjena = 4.0f, // Default
                    TrenutnaZauzetost = 0.5f, // Default
                    SezonalnostFaktor = 1.0f, // Default
                    //Label = l.Status == 3
                })
                .ToListAsync();

            if (!data.Any())
            {
                data = GenerateDummyNotificationData();
            }

            return _mlContext.Data.LoadFromEnumerable(data);
        }

        #region ML Data Classes

        private class WaitingListPrediction
        {
            [ColumnName("PredictedLabel")]
            public bool PredictedLabel { get; set; }

            [ColumnName("Probability")]
            public float AcceptanceProbability { get; set; }

            [ColumnName("Score")]
            public float Score { get; set; }
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
            public bool Label { get; set; }
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
            public bool Label { get; set; }
        }

        private class AcceptancePrediction
        {
            [ColumnName("PredictedLabel")]
            public bool PredictedLabel { get; set; }

            [ColumnName("Probability")]
            public float Probability { get; set; }

            [ColumnName("Score")]
            public float Score { get; set; }
        }

        #endregion
    }
}
#endregion