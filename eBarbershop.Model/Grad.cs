using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Grad
    {
        public int GradId { get; set; }
        public string Naziv { get; set; }

        // Veza sa drzavom
        public int DrzavaId { get; set; }
        public Drzava Drzava { get; set; }

        // Veza sa korisnicima
        public ICollection<Korisnik> Korisnici { get; set; }
    }

}
