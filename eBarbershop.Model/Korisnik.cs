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
        public string Slika { get; set; }

        public int GradId { get; set; }
        public List<string> Uloge => KorisnikUlogas?
                .Select(x => x.Uloga?.Naziv)
                .Where(naziv => !string.IsNullOrEmpty(naziv))
                .ToList(); public virtual ICollection<KorisnikUloga> KorisnikUlogas { get; set; } = new List<KorisnikUloga>();
    }
    
}
