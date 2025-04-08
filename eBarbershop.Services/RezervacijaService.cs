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

        public RezervacijaService(EBarbershop1Context context, IMapper mapper, ICurrentUserService currentUserService)
            : base(context, mapper)
        {
            _currentUserService = currentUserService ?? throw new ArgumentNullException(nameof(currentUserService));
        }

        public override async Task<Model.Rezervacija> Insert(RezervacijaInsertRequest request)
        {
            // Get the currently logged-in user's ID from Authorization
            int loggedInUserId = _currentUserService.GetUserId(); // You'll need to inject a service to get the current user

            // Kreiraj novu rezervaciju
            var entity = new Database.Rezervacija
            {
                KorisnikId = request.KorisnikId, // Barber/employee ID
                KlijentId = loggedInUserId, // Set customer ID to logged-in user
                DatumRezervacije = request.DatumRezervacije,
                UslugaId = request.UslugaId
            };

            // Dohvati uslugu koja je povezana s rezervacijom
            var usluga = await _context.Uslugas
                                        .FirstOrDefaultAsync(u => u.UslugaId == request.UslugaId);

            if (usluga == null)
            {
                throw new Exception("Usluga nije pronađena.");
            }

            // Poveži uslugu sa rezervacijom
            entity.Usluga = usluga;

            // Spremi rezervaciju
            _context.Rezervacija.Add(entity);
            await _context.SaveChangesAsync();

            // Postavi isBooked na true za sve termine (ako je potrebno)
            foreach (var termin in _context.Termin)
            {
                termin.isBooked = true;
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Rezervacija>(entity);
        }


        //public async Task<List<Database.Usluga>> GetUslugeForDateAsync(DateTime datumRezervacije)
        //{
        //    var usluge = await _context.Uslugas
        //        .Where(u => u.Datum == datumRezervacije)
        //        .ToListAsync();

        //    return usluge;
        //}


        public override IQueryable<Database.Rezervacija> AddFilter(IQueryable<Database.Rezervacija> entity, RezervacijaSearchObject obj)
        {

            if (obj.KorisnikID.HasValue)
            {
                entity = entity.Where(x => x.KorisnikId == obj.KorisnikID);
            }
            if (!string.IsNullOrWhiteSpace(obj.imePrezime))
            {
                entity = entity.Where(x => x.Korisnik.Ime.ToLower().Contains(obj.imePrezime.ToLower()) || x.Korisnik.Prezime.ToLower().Contains(obj.imePrezime.ToLower()));
            }
            if(!string.IsNullOrWhiteSpace(obj.Usluga))
            {
                entity = entity.Where(x => x.Usluga.Naziv.ToLower().Contains(obj.Usluga.ToLower()));
            }

            if (obj.IncludeKorisnik == true && !string.IsNullOrEmpty(obj.imePrezime))
            {
                entity = entity.Where(x => x.Korisnik.Ime == obj.imePrezime || x.Korisnik.Prezime == obj.imePrezime);
            }
            if (obj.datumRezervacije.HasValue)
            {
                entity = entity.Where(x => x.DatumRezervacije.Date == obj.datumRezervacije.Value.Date); // Poredi samo datum
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

            return entity;
        }
    }
}
