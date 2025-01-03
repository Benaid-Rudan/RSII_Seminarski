using AutoMapper;
using Azure.Core;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using eBarbershop.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
namespace eBarbershop.Services
{
    public class KorisniciService : IKorisniciService
    {
        EBarbershop1Context _context;
        IMapper _mapper;
           
        public KorisniciService(EBarbershop1Context context, IMapper mapper) 
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<Model.Korisnik> Insert(KorisniciInsertRequest request)
        {
            // Provjera da li su šifre jednake
            if (request.Password != request.PasswordPotvrda)
            {
                throw new Exception("Password i PasswordPotvrda se ne podudaraju!");
            }

            // Generisanje salt-a i hash-a
            var salt = GenerateSalt();
            var hash = GenerateHash(salt, request.Password);

            // Kreiranje novog korisnika
            var entity = new Database.Korisnik
            {
                Ime = request.Ime,
                Prezime = request.Prezime,
                Email = request.Email,
                Username = request.Username,
                PasswordSalt = salt,
                PasswordHash = hash,
                GradId = request.GradId,
                Slika = request.Slika
            };

            await _context.Korisniks.AddAsync(entity); // Asinkrono dodavanje korisnika
            await _context.SaveChangesAsync(); // Asinkrono spremanje korisnika da bismo dobili njegov ID

            // Dodavanje uloga za korisnika
            foreach (var ulogaId in request.UlogeID)
            {
                var korisnikUloga = new Database.KorisnikUloga
                {
                    KorisnikId = entity.KorisnikId, // Povezujemo korisnika s ulogom
                    UlogaId = ulogaId,
                    DatumDodjele = DateTime.Now
                };

                await _context.KorisnikUlogas.AddAsync(korisnikUloga); // Asinkrono dodavanje korisnik-uloze
            }

            await _context.SaveChangesAsync(); // Asinkrono spremanje uloga u bazu

            // Vraćanje rezultata
            return new Model.Korisnik
            {
                KorisnikId = entity.KorisnikId,
                Ime = entity.Ime,
                Prezime = entity.Prezime,
                Email = entity.Email,
                Username = entity.Username,
                GradId = entity.GradId,
                Slika = entity.Slika
            };
        }

        public async Task BeforeInsert(Korisnik entity, KorisniciInsertRequest insert)
        {
            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);
        }

        public static string GenerateSalt()
        {
            RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
            var byteArray = new byte[16];
            provider.GetBytes(byteArray);


            return Convert.ToBase64String(byteArray);
        }
        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }

        public async Task<Model.Korisnik> Update(int id, KorisniciUpdateRequest request)
        {
            // Pronalaženje entiteta asinkrono
            var entity = await _context.Korisniks.FindAsync(id);

            if (entity == null)
            {
                throw new Exception("Korisnik nije pronađen!");
            }

            // Mapiranje podataka iz request objekta u entitet
            _mapper.Map(request, entity);

            // Asinkrono čuvanje izmena u bazi
            await _context.SaveChangesAsync();

            // Mapiranje ažuriranog entiteta nazad u model i vraćanje rezultata
            return _mapper.Map<Model.Korisnik>(entity);
        }

        public IQueryable<Korisnik> AddInclude(IQueryable<Korisnik> query, KorisnikSearchObject? search = null)
        {
            if (search?.IsUlogeIncluded == true)
            {
                query = query.Include("KorisnikUlogas.Uloga");
            }
            return query;
        }

        public IQueryable<Korisnik> AddFilter(IQueryable<Korisnik> entity, KorisnikSearchObject obj)
        {
            if (!string.IsNullOrWhiteSpace(obj.Ime))
            {
                entity = entity.Where(x => x.Ime.ToLower().StartsWith(obj.Ime.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(obj.Prezime))
            {
                entity = entity.Where(x => x.Prezime.ToLower().StartsWith(obj.Prezime.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(obj.Username))
            {
                entity = entity.Where(x => x.Username.StartsWith(obj.Username));
            }

            return entity;
        }

        public eBarbershop.Model.Korisnik AddUloga(int id, KorisniciUlogaUpdateRequest request)
        {
            // Pronađi korisnika
            var user = _context.Korisniks.Include("KorisnikUlogas.Uloga").FirstOrDefault(x => x.KorisnikId == id);
            if (user == null)
                throw new Exception("Korisnik nije pronađen.");

            // Pronađi ulogu
            var uloga = _context.Ulogas.FirstOrDefault(x => x.Naziv.ToLower() == request.Uloga.ToLower());
            if (uloga == null)
                throw new Exception("Uloga nije pronađena.");

            // Provjeri da li korisnik već ima ovu ulogu
            if (user.KorisnikUlogas.Any(x => x.UlogaId == uloga.UlogaId))
                throw new Exception("Korisnik već ima ovu ulogu.");

            // Dodaj novu ulogu korisniku
            var nova = new eBarbershop.Services.Database.KorisnikUloga()
            {
                DatumDodjele = DateTime.Now,
                KorisnikId = id,
                UlogaId = uloga.UlogaId
            };
            _context.KorisnikUlogas.Add(nova);
            _context.SaveChanges();
                
            // Vrati ažuriranog korisnika
            return _mapper.Map<eBarbershop.Model.Korisnik>(user);
        }
        public eBarbershop.Model.Korisnik DeleteUloga(int id, KorisniciUlogaUpdateRequest request)
        {
            // Pronađi korisnika
            var user = _context.Korisniks.Include("KorisnikUlogas.Uloga").FirstOrDefault(x => x.KorisnikId == id);
            if (user == null)
                throw new Exception("Korisnik nije pronađen.");

            // Pronađi ulogu
            var uloga = _context.Ulogas.FirstOrDefault(x => x.Naziv.ToLower() == request.Uloga.ToLower());
            if (uloga == null)
                throw new Exception("Uloga nije pronađena.");

            // Provjeri da li korisnik ima ovu ulogu
            var korisnikUloga = user.KorisnikUlogas.FirstOrDefault(x => x.UlogaId == uloga.UlogaId);
            if (korisnikUloga == null)
                throw new Exception("Korisnik nema ovu ulogu.");

            // Izbriši ulogu
            _context.KorisnikUlogas.Remove(korisnikUloga);
            _context.SaveChanges();

            // Vrati ažuriranog korisnika
            return _mapper.Map<eBarbershop.Model.Korisnik>(user);
        }
        public Model.Korisnik Login(string username, string password)
        {
            var user = _context.Korisniks.Include("KorisnikUlogas.Uloga").FirstOrDefault(x => x.Username == username);

            if (user == null) { throw new Exception("No user found"); }

            var hash = GenerateHash(user.PasswordSalt, password);

            if (user.PasswordHash != hash) { throw new Exception("Wrong password"); }

            return _mapper.Map<Model.Korisnik>(user);
        }

        public virtual async Task<List<Model.Korisnik>> Get(KorisnikSearchObject? search = null)
        {
            var query = _context.Set<Korisnik>().AsQueryable();
            query = AddFilter(query, search);
            query = AddInclude(query, search);
            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Take(search.PageSize.Value).Skip(search.Page.Value * search.PageSize.Value);
            }
            var list = await query.ToListAsync();
            return _mapper.Map<List<Model.Korisnik>>(list);

        }
        public virtual async Task<Model.Korisnik> GetById(int id)
        {
            var entity = await _context.Set<Korisnik>().FindAsync(id);
            return _mapper.Map<Model.Korisnik>(entity);
        }
        public async Task<Model.Korisnik> Delete(int id)
        {
            var set = _context.Set<Korisnik>();
            var entity = await set.FindAsync(id);
            var temp = entity;

            if (entity != null)
                _context.Remove(entity);

            await _context.SaveChangesAsync();
            return _mapper.Map<Model.Korisnik>(temp);
        }
    }
}

