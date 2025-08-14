using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class ListaCekanjaService : BaseCRUDService<Model.ListaCekanja, Database.ListaCekanja, ListaCekanjaSearchObject, ListaCekanjaInsertRequest, ListaCekanjaUpdateRequest>, IListaCekanjaService
    {
        private readonly IWaitingListMLService _mlService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMailService _emailService;
        private readonly ILogger<ListaCekanjaService> _logger;

        public ListaCekanjaService(
            EBarbershop1Context context,
            IMapper mapper,
            IWaitingListMLService mlService,
            ICurrentUserService currentUserService,
            IMailService emailService,
            ILogger<ListaCekanjaService> logger)
            : base(context, mapper)
        {
            _mlService = mlService;
            _currentUserService = currentUserService;
            _emailService = emailService;
            _logger = logger;
        }

        // Updated JoinWaitingList method in ListaCekanjaService.cs
        // Updated JoinWaitingList method in ListaCekanjaService.cs
        public async Task<Model.ListaCekanja> JoinWaitingList(ListaCekanjaInsertRequest request)
        {
            var klijentId = _currentUserService.GetUserId();

            // Provjeri da li klijent već čeka za isti termin/frizera/uslugu
            var postojeciZahtjev = await _context.ListaCekanja
                .FirstOrDefaultAsync(l => l.KlijentId == klijentId &&
                                        l.FrizerId == request.FrizerId &&
                                        l.UslugaId == request.UslugaId &&
                                        l.ZeljeniDatum.Date == request.ZeljeniDatum.Date);
                                        
                                        //l.Status == 1);

            if (postojeciZahtjev != null)
            {
                throw new InvalidOperationException("Već ste na listi čekanja za ovaj termin.");
            }

            // Provjeri dostupnost termina
            var dostupanTermin = await _context.Termin
                .AnyAsync(t => t.KorisnikID == request.FrizerId &&
                             t.Vrijeme.Date == request.ZeljeniDatum.Date &&
                             !t.isBooked);

            if (dostupanTermin)
            {
                throw new InvalidOperationException("Termin je dostupan za direktnu rezervaciju.");
            }

            // Kreiraj novu stavku liste čekanja s default vrijednostima
            var entity = new Database.ListaCekanja
            {
                KlijentId = klijentId,
                FrizerId = request.FrizerId,
                UslugaId = request.UslugaId,
                ZeljeniDatum = request.ZeljeniDatum,
                //ZeljenoVrijeme = request.ParsedZeljenoVrijeme,
                DatumPrijave = DateTime.Now,
                //Status = (int)StatusCekanja.Aktivna, // Aktivna
                DatumIsteka = DateTime.Now.AddDays(request.DaniDoIsteka),
                Napomena = request.Napomena,
                NotifikacijaPoslana = false,
                Prioritet = 50, // Default value
                MLSkor = 0.5 // Default value
            };

            // Pokuša izračunati ML vrijednosti, ali nastavi ako ne uspije
            try
            {
                entity.Prioritet = await _mlService.CalculatePriorityScore(
                    klijentId, request.FrizerId, request.UslugaId, request.ZeljeniDatum);

                entity.MLSkor = await _mlService.PredictAcceptanceProbability(klijentId, 0);

                _logger.LogInformation($"ML scores calculated - Priority: {entity.Prioritet}, ML Score: {entity.MLSkor}");
            }
            catch (Exception ex)
            {
                _logger.LogWarning($"ML services failed, using default values: {ex.Message}");
                // Keep the default values we set above
                entity.Prioritet = 50 + (int)((request.ZeljeniDatum - DateTime.Now).TotalDays);
                entity.MLSkor = 0.5;
            }

            await _context.ListaCekanja.AddAsync(entity);
            await _context.SaveChangesAsync();

            // Pošalji potvrdu emailom
            try
            {
                var klijent = await _context.Korisnik.FindAsync(klijentId);
                var frizer = await _context.Korisnik.FindAsync(request.FrizerId);
                var usluga = await _context.Usluga.FindAsync(request.UslugaId);

                if (klijent?.Email != null)
                {
                    var mailObject = new MailObject
                    {
                        mailAdresa = klijent.Email,
                        subject = "Dodani ste na listu čekanja",
                        poruka = $"Poštovani {klijent.Ime},<br/><br/>Uspješno ste dodani na listu čekanja za:<br/>" +
                                $"<strong>Frizer:</strong> {frizer?.Ime} {frizer?.Prezime}<br/>" +
                                $"<strong>Usluga:</strong> {usluga?.Naziv}<br/>" +
                                $"<strong>Željeni datum:</strong> {request.ZeljeniDatum:dd.MM.yyyy}<br/>" +
                                $"<strong>Vaš prioritet:</strong> {entity.Prioritet}/100<br/><br/>" +
                                "Obavijestit ćemo vas kada se oslobodi termin!"
                    };
                    await _emailService.startConnection(mailObject);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning($"Failed to send email notification: {ex.Message}");
                // Continue without email - this shouldn't block the operation
            }

            _logger.LogInformation($"Korisnik {klijentId} dodan na listu čekanja za frizera {request.FrizerId}");

            return _mapper.Map<Model.ListaCekanja>(entity);
        }

        public async Task<bool> RemoveFromWaitingList(int listaCekanjaId)
        {
            var klijentId = _currentUserService.GetUserId();
            var stavka = await _context.ListaCekanja
                .FirstOrDefaultAsync(l => l.ListaCekanjaId == listaCekanjaId && l.KlijentId == klijentId);

            if (stavka == null) return false;

            //stavka.Status = 5; // Otkazana
            await _context.SaveChangesAsync();

            _logger.LogInformation($"Korisnik {klijentId} uklonjen sa liste čekanja {listaCekanjaId}");
            return true;
        }

        public async Task<List<Model.ListaCekanja>> GetWaitingListForBarber(int frizerId, DateTime? datum = null)
        {
            // Start with base query and include related entities first
            var query = _context.ListaCekanja
                .Include(l => l.Klijent)
                .Include(l => l.Usluga)
                .Where(l => l.FrizerId == frizerId);

            // Apply date filter if provided
            if (datum.HasValue)
            {
                query = query.Where(l => l.ZeljeniDatum.Date == datum.Value.Date);
            }

            var lista = await query
                .OrderByDescending(l => l.Prioritet)
                .ThenBy(l => l.DatumPrijave)
                .ToListAsync();

            return _mapper.Map<List<Model.ListaCekanja>>(lista);
        }

        public async Task<List<Model.ListaCekanja>> GetMyWaitingList(int klijentId)
        {
            _logger.LogInformation($"Fetching waiting list for client {klijentId}");

            var items = await _context.ListaCekanja
                .Where(l => l.KlijentId == klijentId)
                .Include(l => l.Frizer)
                .Include(l => l.Usluga)
                .OrderBy(l => l.ZeljeniDatum)
                .ToListAsync();

            _logger.LogInformation($"Found {items.Count} items for client {klijentId}");
            return _mapper.Map<List<Model.ListaCekanja>>(items);
        }

        public async Task ProcessAvailableSlot(int terminId)
        {
            var termin = await _context.Termin
                .Include(t => t.Rezervacija)
                .FirstOrDefaultAsync(t => t.TerminId == terminId && !t.isBooked);

            if (termin == null)
            {
                _logger.LogWarning($"Termin {terminId} nije dostupan ili ne postoji");
                return;
            }

            // Pronađi relevantne stavke liste čekanja
            var potencijalniKandidati = await _context.ListaCekanja
                .Where(l => l.FrizerId == termin.KorisnikID &&
                           l.ZeljeniDatum.Date <= termin.Vrijeme.Date &&
                           //l.Status == 1 &&
                           (!l.ZeljenoVrijeme.HasValue ||
                            Math.Abs((l.ZeljenoVrijeme.Value - termin.Vrijeme.TimeOfDay).TotalMinutes) <= 60))
                .Include(l => l.Klijent)
                .Include(l => l.Usluga)
                .ToListAsync();

            if (!potencijalniKandidati.Any())
            {
                _logger.LogInformation($"Nema kandidata za termin {terminId}");
                return;
            }

            List<int> rangiranKandidati;

            try
            {
                // Koristi ML za pronalaženje najboljih kandidata
                var kandidatIds = potencijalniKandidati.Select(k => k.ListaCekanjaId).ToList();
                rangiranKandidati = await _mlService.FindBestCandidatesForSlot(terminId, kandidatIds);
            }
            catch (Exception ex)
            {
                _logger.LogWarning($"ML candidate ranking failed, using fallback: {ex.Message}");
                // Fallback sorting by priority and waiting time
                rangiranKandidati = potencijalniKandidati
                    .OrderByDescending(k => k.Prioritet)
                    .ThenBy(k => k.DatumPrijave)
                    .Select(k => k.ListaCekanjaId)
                    .ToList();
            }

            // Notificiraj do 3 najbolja kandidata
            var brojNotifikacija = Math.Min(3, rangiranKandidati.Count);

            for (int i = 0; i < brojNotifikacija; i++)
            {
                var kandidatId = rangiranKandidati[i];
                var kandidat = potencijalniKandidati.First(k => k.ListaCekanjaId == kandidatId);

                try
                {
                    await SendNotification(kandidat, termin);

                    // Dodaj kašnjenje između notifikacija da ne spamamo
                    if (i < brojNotifikacija - 1)
                    {
                        await Task.Delay(5000); // 5 sekundi
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Failed to send notification to candidate {kandidatId}: {ex.Message}");
                    // Continue with other candidates
                }
            }

            _logger.LogInformation($"Poslano {brojNotifikacija} notifikacija za termin {terminId}");
        }

        public async Task<bool> RespondToNotification(int notifikacijaId, bool accepted)
        {
            var klijentId = _currentUserService.GetUserId();
            var notifikacija = await _context.NotifikacijaListeCekanja
                .Include(n => n.ListaCekanja)
                .Include(n => n.Termin)
                .FirstOrDefaultAsync(n => n.NotifikacijaId == notifikacijaId &&
                                        n.ListaCekanja.KlijentId == klijentId);

            if (notifikacija == null || notifikacija.Odgovoreno)
                return false;

            if (notifikacija.DatumIsteka < DateTime.Now)
            {
                // Notifikacija je istekla
                notifikacija.Odgovoreno = true;
                notifikacija.Prihvaceno = false;
                await _context.SaveChangesAsync();
                return false;
            }

            notifikacija.Odgovoreno = true;
            notifikacija.Prihvaceno = accepted;

            if (accepted)
            {
                // Kreiraj rezervaciju
                var rezervacija = new Database.Rezervacija
                {
                    KorisnikId = notifikacija.Termin.KorisnikID,
                    KlijentId = klijentId,
                    UslugaId = notifikacija.ListaCekanja.UslugaId,
                    DatumRezervacije = notifikacija.Termin.Vrijeme
                };

                await _context.Rezervacija.AddAsync(rezervacija);
                await _context.SaveChangesAsync();

                // Ažuriraj termin
                notifikacija.Termin.isBooked = true;
                notifikacija.Termin.RezervacijaId = rezervacija.RezervacijaId;

                // Ažuriraj listu čekanja
                //notifikacija.ListaCekanja.Status = 3; // Prihvacena

                // Otkaži ostale notifikacije za isti termin
                var ostaleNotifikacije = await _context.NotifikacijaListeCekanja
                    .Where(n => n.TerminId == notifikacija.TerminId &&
                               n.NotifikacijaId != notifikacijaId &&
                               !n.Odgovoreno)
                    .ToListAsync();

                foreach (var druga in ostaleNotifikacije)
                {
                    druga.Odgovoreno = true;
                    druga.Prihvaceno = false;
                }

                _logger.LogInformation($"Rezervacija kreirana za korisnika {klijentId}, termin {notifikacija.TerminId}");
            }
            else
            {
                // Ako korisnik nije prihvatio, ostavi listu čekanja aktivnom
                _logger.LogInformation($"Korisnik {klijentId} odbio notifikaciju {notifikacijaId}");
            }

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task ProcessExpiredNotifications()
        {
            var istekleNotifikacije = await _context.NotifikacijaListeCekanja
                .Include(n => n.ListaCekanja)
                .Where(n => !n.Odgovoreno && n.DatumIsteka < DateTime.Now)
                .ToListAsync();

            foreach (var notifikacija in istekleNotifikacije)
            {
                notifikacija.Odgovoreno = true;
                notifikacija.Prihvaceno = false;
            }

            // Također provjeri istekle stavke liste čekanja
            var istekleStavke = await _context.ListaCekanja
                .Where(l => l.DatumIsteka < DateTime.Now)
                .ToListAsync();

            foreach (var stavka in istekleStavke)
            {
                //stavka.Status = 4; // Istekla
            }

            if (istekleNotifikacije.Any() || istekleStavke.Any())
            {
                await _context.SaveChangesAsync();
                _logger.LogInformation($"Obrađeno {istekleNotifikacije.Count} isteklih notifikacija i {istekleStavke.Count} isteklih stavki");
            }
        }

        public async Task OptimizeWaitingListOrder()
        {
            try
            {
                var aktivneStavke = await _context.ListaCekanja
                    //.Where(l => l.Status == 1)
                    .Include(l => l.Klijent)
                    .Include(l => l.Frizer)
                    .Include(l => l.Usluga)
                    .ToListAsync();

                if (!aktivneStavke.Any()) return;

                var modelStavke = _mapper.Map<List<Model.ListaCekanja>>(aktivneStavke);

                List<Model.ListaCekanja> optimizovaneStavke;

                try
                {
                    optimizovaneStavke = await _mlService.GetOptimalNotificationOrder(modelStavke);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning($"ML optimization failed, using fallback sorting: {ex.Message}");
                    // Fallback to simple priority sorting
                    optimizovaneStavke = modelStavke
                        .OrderByDescending(s => s.Prioritet)
                        .ThenBy(s => s.DatumPrijave)
                        .ToList();
                }

                // Ažuriraj prioritete
                for (int i = 0; i < optimizovaneStavke.Count; i++)
                {
                    var dbStavka = aktivneStavke.First(s => s.ListaCekanjaId == optimizovaneStavke[i].ListaCekanjaId);
                    dbStavka.Prioritet = optimizovaneStavke[i].Prioritet;
                    dbStavka.MLSkor = optimizovaneStavke[i].MLSkor;
                }

                await _context.SaveChangesAsync();
                _logger.LogInformation($"Optimizovano {aktivneStavke.Count} stavki liste čekanja");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to optimize waiting list: {ex.Message}");
            }
        }


        public async Task<List<Model.NotifikacijaListeCekanja>> GetPendingNotifications(int klijentId)
        {
            var notifikacije = await _context.NotifikacijaListeCekanja
                .Include(n => n.ListaCekanja)
                .Include(n => n.Termin)
                    .ThenInclude(t => t.Korisnik)
                .Where(n => n.ListaCekanja.KlijentId == klijentId &&
                           !n.Odgovoreno &&
                           n.DatumIsteka > DateTime.Now)
                .OrderBy(n => n.DatumIsteka)
                .ToListAsync();

            return _mapper.Map<List<Model.NotifikacijaListeCekanja>>(notifikacije);
        }

        public async Task<WaitingListStats> GetWaitingListStats(int? frizerId = null)
        {
            var query = _context.ListaCekanja.AsQueryable();

            if (frizerId.HasValue)
            {
                query = query.Where(l => l.FrizerId == frizerId.Value);
            }

            //var aktivneStavke = await query.CountAsync(l => l.Status == 1);
            var ukupnoNotifikacija = await _context.NotifikacijaListeCekanja.CountAsync();

            var prosjekCekanja = await query
                //.Where(l => l.Status == 3 || l.Status == 4) // Prihvacene ili istekle
                .AverageAsync(l => (double?)(l.DatumNotifikacije ?? DateTime.Now).Subtract(l.DatumPrijave).TotalDays) ?? 0;

            var stopaPrihvacanja = await _context.NotifikacijaListeCekanja
                .Where(n => n.Odgovoreno)
                .AverageAsync(n => n.Prihvaceno ? 1.0 : 0.0);

            var popularniTermini = await query
                .Where(l => l.ZeljenoVrijeme.HasValue)
                .GroupBy(l => l.ZeljenoVrijeme.Value.Hours)
                .Select(g => new PopularTimeSlot
                {
                    Sat = g.Key,
                    BrojZahtjeva = g.Count(),
                    //PostotakPrihvacanja = g.Average(x => x.Status == 3 ? 1.0 : 0.0)
                })
                .OrderByDescending(p => p.BrojZahtjeva)
                .Take(5)
                .ToListAsync();

            return new WaitingListStats
            {
                //TotalActivneStavke = aktivneStavke,
                TotalNotifikacije = ukupnoNotifikacija,
                ProsjekVrijemeCekanja = prosjekCekanja,
                StopaPrihvacanja = stopaPrihvacanja,
                NajpopularnijiTermini = popularniTermini
            };
        }

        #region Helper Methods

        private async Task SendNotification(Database.ListaCekanja kandidat, Database.Termin termin)
        {
            var notifikacija = new Database.NotifikacijaListeCekanja
            {
                ListaCekanjaId = kandidat.ListaCekanjaId,
                TerminId = termin.TerminId,
                DatumNotifikacije = DateTime.Now,
                DatumIsteka = DateTime.Now.AddHours(2), // 2 sata za odgovor
                Odgovoreno = false,
                Prihvaceno = false,
                PorukaNofitikacije = $"Dostupan je termin kod {termin.Korisnik?.Ime} {termin.Korisnik?.Prezime} " +
                                   $"dana {termin.Vrijeme:dd.MM.yyyy} u {termin.Vrijeme:HH:mm}h. " +
                                   $"Imate 2 sata da potvrdite rezervaciju."
            };

            await _context.NotifikacijaListeCekanja.AddAsync(notifikacija);
            //kandidat.Status = 2; // Notificirana
            kandidat.DatumNotifikacije = DateTime.Now;
            kandidat.NotifikacijaPoslana = true;

            // Pošalji email notifikaciju
            if (kandidat.Klijent?.Email != null)
            {
                var mailObject = new MailObject
                {
                    mailAdresa = kandidat.Klijent.Email,
                    subject = "🎉 Dostupan je termin!",
                    poruka = $"Poštovani {kandidat.Klijent.Ime},<br/><br/>" +
                            $"Odličan je vrijeme! Dostupan je termin koji ste čekali:<br/><br/>" +
                            $"<strong>Frizer:</strong> {termin.Korisnik?.Ime} {termin.Korisnik?.Prezime}<br/>" +
                            $"<strong>Datum:</strong> {termin.Vrijeme:dd.MM.yyyy}<br/>" +
                            $"<strong>Vrijeme:</strong> {termin.Vrijeme:HH:mm}h<br/>" +
                            $"<strong>Usluga:</strong> {kandidat.Usluga?.Naziv}<br/><br/>" +
                            $"⏰ <strong>Važno:</strong> Imate 2 sata da potvrdite rezervaciju putem aplikacije.<br/>" +
                            $"Nakon tog vremena, termin će biti ponuđen drugome.<br/><br/>" +
                            $"Prijavite se u aplikaciju i potvrdite rezervaciju!"
                };
                await _emailService.startConnection(mailObject);
            }

            await _context.SaveChangesAsync();
        }

        #endregion

        #region Override Methods

        public override IQueryable<Database.ListaCekanja> AddFilter(IQueryable<Database.ListaCekanja> query, ListaCekanjaSearchObject search)
        {
            if (search?.KlijentId.HasValue == true)
            {
                query = query.Where(l => l.KlijentId == search.KlijentId.Value);
            }

            if (search?.FrizerId.HasValue == true)
            {
                query = query.Where(l => l.FrizerId == search.FrizerId.Value);
            }

            if (search?.UslugaId.HasValue == true)
            {
                query = query.Where(l => l.UslugaId == search.UslugaId.Value);
            }

            //if (search?.Status.HasValue == true)
            //{
            //    //query = query.Where(l => l.Status == (int)search.Status.Value);
            //}

            if (search?.DatumOd.HasValue == true)
            {
                query = query.Where(l => l.ZeljeniDatum.Date >= search.DatumOd.Value.Date);
            }

            if (search?.DatumDo.HasValue == true)
            {
                query = query.Where(l => l.ZeljeniDatum.Date <= search.DatumDo.Value.Date);
            }

            // Sortiranje
            if (search?.SortByPrioritet == true)
            {
                query = query.OrderByDescending(l => l.Prioritet).ThenBy(l => l.DatumPrijave);
            }
            else if (search?.SortByMLSkor == true)
            {
                query = query.OrderByDescending(l => l.MLSkor).ThenBy(l => l.DatumPrijave);
            }

            return query;
        }

        public override IQueryable<Database.ListaCekanja> AddInclude(IQueryable<Database.ListaCekanja> query, ListaCekanjaSearchObject search)
        {
            if (search?.IncludeKlijent == true)
            {
                query = query.Include(l => l.Klijent);
            }

            if (search?.IncludeFrizer == true)
            {
                query = query.Include(l => l.Frizer);
            }

            if (search?.IncludeUsluga == true)
            {
                query = query.Include(l => l.Usluga);
            }

            return query;
        }

        #endregion
    }
}