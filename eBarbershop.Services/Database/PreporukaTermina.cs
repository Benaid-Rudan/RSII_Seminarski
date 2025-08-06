using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services.Database
{
    public class PreporukaTermina
    {
        [Key]
        public int PreporukaId { get; set; }
        public int KlijentId { get; set; }
        public Korisnik Klijent { get; set; }
        public DateTime PreporuceniTermin { get; set; }
        public int KorisnikId { get; set; } // frizer
        public Korisnik Korisnik { get; set; }
        public int UslugaId { get; set; }
        public Usluga Usluga { get; set; }
        public double SkorPovjerenja { get; set; } // ML confidence score
        public string RazlogPreporuke { get; set; }
        public bool IsAccepted { get; set; }
    }
}
