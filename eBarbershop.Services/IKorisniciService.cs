using eBarbershop.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public interface  IKorisniciService : ICRUDService<Model.Korisnik,Model.SearchObjects.KorisnikSearchObject,Model.Requests.KorisniciInsertRequest,Model.Requests.KorisniciUpdateRequest>
    {

    }
}
