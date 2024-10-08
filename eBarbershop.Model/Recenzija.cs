using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Recenzija
    {
        public int RecenzijaId { get; set; }
        public string Komentar { get; set; }
        public int Ocjena { get; set; }
        public DateTime Datum { get; set; }

        // Veza sa korisnikom
        public int KorisnikId { get; set; }
        public Korisnik Korisnik { get; set; }

        // Veza sa uslugom ili proizvodom
        public int? UslugaId { get; set; }
        public Usluga Usluga { get; set; }

        public int? ProizvodId { get; set; }
        public Proizvod Proizvod { get; set; }
    }

}
