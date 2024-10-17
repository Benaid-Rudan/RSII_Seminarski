using AutoMapper;
using eBarbershop.Model.Requests;
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
        public IMapper _mapper { get; set; }     
        public KorisniciService(EBarbershop1Context context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<List<Model.Korisnik>> Get()
        {
            var entityList = await _context.Korisniks.ToListAsync();

            
            return _mapper.Map<List<Model.Korisnik>>(entityList);
        }

        public Model.Korisnik Insert(KorisniciInsertRequest request)
        {
            var entity = new Korisnik();
            _mapper.Map(request, entity);

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);


            _context.Korisniks.Add(entity);
            _context.SaveChanges();

            return _mapper.Map<Model.Korisnik>(entity);
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

        public Model.Korisnik Update(int id, KorisniciUpdateRequest request)
        {
            var entity = _context.Korisniks.Find(id);
            _mapper.Map(request, entity);
            _context.SaveChanges();
            return _mapper.Map<Model.Korisnik>(entity);
        }
    }
}

