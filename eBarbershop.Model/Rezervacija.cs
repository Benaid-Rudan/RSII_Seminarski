using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Rezervacija
    {
        public int RezervacijaId { get; set; }
        public DateTime DatumRezervacije { get; set; }
        //public DateTime Termin { get; set; }

        // Veza sa korisnikom
        public int KorisnikId { get; set; }
        public Korisnik Korisnik { get; set; }

        // Veza sa uslugom
        public int UslugaId { get; set; }
        public Usluga Usluga { get; set; }
    }

}
