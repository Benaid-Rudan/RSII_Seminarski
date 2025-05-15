using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class RezervacijaService : BaseCRUDService<Model.Rezervacija, Database.Rezervacija, RezervacijaSearchObject , RezervacijaInsertRequest, RezervacijaUpdateRequest>, IRezervacijaService 
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IMailService _emailService;
        public RezervacijaService(EBarbershop1Context context, IMapper mapper, ICurrentUserService currentUserService, IMailService emailService)
            : base(context, mapper)
        {
            _currentUserService = currentUserService ?? throw new ArgumentNullException(nameof(currentUserService));
            _emailService = emailService ?? throw new ArgumentNullException(nameof(emailService));
        }

        public override async Task<Model.Rezervacija> Insert(RezervacijaInsertRequest request)
        {
            int loggedInUserId = _currentUserService.GetUserId(); 
            var entity = new Database.Rezervacija
            {
                KorisnikId = request.KorisnikId, 
                KlijentId = loggedInUserId, 
                DatumRezervacije = request.DatumRezervacije,
                UslugaId = request.UslugaId
            };

            var usluga = await _context.Usluga
                                        .FirstOrDefaultAsync(u => u.UslugaId == request.UslugaId);

            if (usluga == null)
            {
                throw new Exception("Usluga nije pronađena.");
            }

            entity.Usluga = usluga;

            _context.Rezervacija.Add(entity);
            await _context.SaveChangesAsync();

            var klijent = await _context.Korisnik.FindAsync(loggedInUserId);
            
            if (klijent != null && !string.IsNullOrEmpty(klijent.Email))
            {
                var subject = "Potvrda rezervacije";
                var body = $"Poštovani {klijent.Ime},<br/><br/>Uspješno ste rezervisali uslugu: <strong>{usluga.Naziv}</strong> Provjerite aplikaciju za više detalja </strong>.<br/><br/>Hvala što koristite eBarbershop!";
                var mailObject = new MailObject
                {
                    mailAdresa = klijent.Email,
                    subject = subject,
                    poruka = body
                };
                await _emailService.startConnection(mailObject);
            }


            foreach (var termin in _context.Termin)
            {
                termin.isBooked = true;
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Rezervacija>(entity);
        }



        public override IQueryable<Database.Rezervacija> AddFilter(IQueryable<Database.Rezervacija> entity, RezervacijaSearchObject obj)
        {

            if (obj.KlijentId.HasValue)
            {
                entity = entity.Where(x => x.KlijentId == obj.KlijentId);
            }
            if (!string.IsNullOrWhiteSpace(obj.imePrezimeKlijenta))
            {
                entity = entity.Where(x => x.Klijent.Ime.ToLower().Contains(obj.imePrezimeKlijenta.ToLower()) || x.Klijent.Prezime.ToLower().Contains(obj.imePrezimeKlijenta.ToLower()));
            }
            if (!string.IsNullOrWhiteSpace(obj.imePrezimeFrizera))
            {
                entity = entity.Where(x => x.Korisnik.Ime.ToLower().Contains(obj.imePrezimeFrizera.ToLower()) || x.Korisnik.Prezime.ToLower().Contains(obj.imePrezimeFrizera.ToLower()));
            }
            if (!string.IsNullOrWhiteSpace(obj.Usluga))
            {
                entity = entity.Where(x => x.Usluga.Naziv.ToLower().Contains(obj.Usluga.ToLower()));
            }

            
            if (obj.datumRezervacije.HasValue)
            {
                entity = entity.Where(x => x.DatumRezervacije.Date == obj.datumRezervacije.Value.Date);
            }
            if (obj.DatumOd.HasValue)
            {
                entity = entity.Where(x => x.Termins.Any(t => t.Vrijeme.Date >= obj.DatumOd.Value.Date));
            }
            if (obj.DatumDo.HasValue)
            {
                entity = entity.Where(x => x.Termins.Any(t => t.Vrijeme.Date <= obj.DatumDo.Value.Date));
            }
            if (obj.KlijentId.HasValue)
            {
                entity = entity.Where(x => x.KlijentId == obj.KlijentId);
            }
            return entity;
        }

        public override IQueryable<Database.Rezervacija> AddInclude(IQueryable<Database.Rezervacija> entity, RezervacijaSearchObject obj)
        {

            if (obj.IncludeKorisnik == true)
            {
                entity = entity.Include(y => y.Korisnik);
            }

            if (obj.IncludeUsluga == true)
            {
                entity = entity.Include(y => y.Usluga);
            }
            if (obj.IncludeKlijent == true)
            {
                entity = entity.Include(y => y.Klijent);
            }



            return entity;
        }
        public override async Task<Model.Rezervacija> Delete(int rezervacijaId)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var rezervacija = await _context.Rezervacija
                    .Include(r => r.Termins) 
                    .FirstOrDefaultAsync(r => r.RezervacijaId == rezervacijaId);

                if (rezervacija != null)
                {
                    foreach (var termin in rezervacija.Termins.ToList())
                    {
                        termin.isBooked = false;
                        _context.Termin.Remove(termin);
                    }

                    await _context.SaveChangesAsync();

                    _context.Rezervacija.Remove(rezervacija);
                    await _context.SaveChangesAsync();

                    await transaction.CommitAsync();
                    return _mapper.Map<Model.Rezervacija>(rezervacija);
                }

                return null;
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

    }
}
