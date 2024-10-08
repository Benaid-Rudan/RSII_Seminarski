using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Korisnik
    {
        public int KorisnikId { get; set; }
        public string Ime { get; set; }
        public string Prezime { get; set; }
        public string Email { get; set; }
        public string Username { get; set; }
        public string PasswordHash { get; set; }
        public string PasswordSalt { get; set; }

        // Veza sa gradom
        public int GradId { get; set; }
        public Grad Grad { get; set; }

        // Veza sa ulogama
        public ICollection<KorisnikUloga> KorisnikUloge { get; set; }

        // Veza sa narudžbama i rezervacijama
        public ICollection<Narudzba> Narudzbe { get; set; }
        public ICollection<Rezervacija> Rezervacije { get; set; }
    }
    
}
