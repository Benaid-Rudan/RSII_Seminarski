using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Termin
    {
        public int TerminId { get; set; }
        [DisplayName("Termin kod")]
        public string TerminUposelnik => $"{Korisnik?.Ime} {Korisnik?.Prezime}";
        public DateTime Vrijeme { get; set; }

        public int RezervacijaId { get; set; }
        public Rezervacija Rezervacija { get; set; }
        public bool isBooked { get; set; }

        [Browsable(false)]
        public int KorisnikID { get; set; }
        [Browsable(false)]
        public Korisnik Korisnik { get; set; }

    }

}
