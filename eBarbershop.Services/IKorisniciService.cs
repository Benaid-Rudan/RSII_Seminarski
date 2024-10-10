using eBarbershop.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public interface  IKorisniciService
    {
        List<Model.Korisnik> Get();
        Model.Korisnik Insert(KorisniciInsertRequest request);
        Model.Korisnik Update(int id, KorisniciUpdateRequest request);

    }
}
