using eBarbershop.Model;
using eBarbershop.Model.Requests;
using eBarbershop.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public interface IKorisniciService
    {
        Model.Korisnik AddUloga(int id, KorisniciUlogaUpdateRequest request);
        Model.Korisnik DeleteUloga(int id, KorisniciUlogaUpdateRequest request);
        Model.Korisnik Login(string username, string password);
        Task<Model.Korisnik> Insert(KorisniciInsertRequest insert);
        Task<Model.Korisnik> Update(int id, KorisniciUpdateRequest update);
        Task<List<Model.Korisnik>> Get(KorisnikSearchObject search = null);
        Task<Model.Korisnik> GetById(int id);
        Task<Model.Korisnik> Delete(int id);

    }
}
