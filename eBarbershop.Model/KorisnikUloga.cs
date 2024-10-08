using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class KorisnikUloga
    {
        public int KorisnikUlogaId { get; set; }

        // Veza sa korisnikom
        public int KorisnikId { get; set; }
        public Korisnik Korisnik { get; set; }

        // Veza sa ulogom
        public int UlogaId { get; set; }
        public Uloga Uloga { get; set; }

        public DateTime DatumDodjele { get; set; }
    }

}
