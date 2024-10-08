using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Uloga
    {
        public int UlogaId { get; set; }
        public string Naziv { get; set; }

        // Veza sa korisnicima
        public ICollection<KorisnikUloga> KorisnikUloge { get; set; }
    }

}
