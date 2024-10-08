using eBarbershop.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services
{
    public interface IProizvodiService
    {
        IList<Proizvod> Get();
    }
}
