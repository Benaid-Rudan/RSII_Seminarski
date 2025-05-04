using AutoMapper;
using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public class TerminService : BaseCRUDService<Model.Termin, Database.Termin, TerminSearchObject , TerminInsertRequest, TerminUpdateRequest>, ITerminService 
    {
        private readonly INotificationService _notificationService;
        public TerminService(EBarbershop1Context context, IMapper mapper, INotificationService notificationService)
        : base(context, mapper)
        {
            _notificationService = notificationService;
        }
        public override async Task<Model.Termin> Insert(TerminInsertRequest request)
        {
            var frizer = await _context.Korisnik.FindAsync(request.KorisnikID);
            if (frizer == null)
                throw new Exception("Frizer nije pronađen");

            var klijent = await _context.Korisnik.FindAsync(request.KlijentId);
            if (klijent == null)
                throw new Exception("Klijent nije pronađen");

            var rezervacija = await _context.Rezervacija.FindAsync(request.RezervacijaId);
            if (rezervacija == null)
                throw new Exception("Rezervacija nije pronađena");

            var entity = _mapper.Map<Database.Termin>(request);
            entity.isBooked = true; 

            await _context.Termin.AddAsync(entity);
            await _context.SaveChangesAsync();
            return _mapper.Map<Model.Termin>(entity);
        }
        public override async Task<Model.Termin> Delete(int terminId)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var termin = await _context.Termin.FindAsync(terminId);
                if (termin != null)
                {
                    var rezervacijaId = termin.RezervacijaId;

                    // Prvo briši termin
                    _context.Termin.Remove(termin);
                    await _context.SaveChangesAsync();

                    // Zatim briši rezervaciju ako postoji
                    var rezervacija = await _context.Rezervacija.FindAsync(rezervacijaId);
                    if (rezervacija != null)
                    {
                        _context.Rezervacija.Remove(rezervacija);
                        await _context.SaveChangesAsync();
                    }

                    await transaction.CommitAsync();
                    return _mapper.Map<Model.Termin>(termin);
                }

                return null;
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }



        public void BeforeInsert(TerminInsertRequest insert, Database.Termin entity)
        {
            entity.isBooked = true;

        }

        public override IQueryable<Database.Termin> AddInclude(IQueryable<Database.Termin> entity, TerminSearchObject obj)
        {
            if (obj.IncludeKorisnik == true)
            {
                entity = entity.Include(x => x.Korisnik);

            }
            if (obj.IncludeRezervacija == true)
            {
                entity = entity.Include(x => x.Rezervacija)
                    .ThenInclude(x=> x.Usluga);

            }
            if (obj.IncludeKlijent == true) // Dodajte ovaj property u TerminSearchObject
            {
                entity = entity.Include(x => x.Klijent);
            }

            return entity;
        }

        public override IQueryable<Database.Termin> AddFilter(IQueryable<Database.Termin> entity, TerminSearchObject obj)
        {
            if (obj.KorisnikID.HasValue)
            {
                entity = entity.Where(x => x.KorisnikID == obj.KorisnikID);
            }
            if (!string.IsNullOrWhiteSpace(obj.imePrezime))
            {
                entity = entity.Where(x => x.Korisnik.Ime.ToLower().Contains(obj.imePrezime.ToLower()) || x.Korisnik.Prezime.ToLower().Contains(obj.imePrezime.ToLower()));
            }

            if (obj.Datum.HasValue)
            {
                entity = entity.Where(x => x.Vrijeme.Date == obj.Datum.Value);
            }

            if (obj.DatumOd.HasValue)
            {
                entity = entity.Where(x => x.Vrijeme.Date >= obj.DatumOd.Value);
            }

            if (obj.DatumDo.HasValue)
            {
                entity = entity.Where(x => x.Vrijeme.Date <= obj.DatumDo.Value);
            }

            if (obj.isBooked.HasValue)
            {
                entity = entity.Where(x => x.isBooked == obj.isBooked);
            }

            return entity;
        }


    }
}
