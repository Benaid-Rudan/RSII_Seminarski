using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class NarudzbaProizvodi
    {
        public int NarudzbaProizvodiId { get; set; }

        public int NarudzbaId { get; set; }

        public int ProizvodId { get; set; }
        public virtual Proizvod Proizvod { get; set; }

        public int Kolicina { get; set; }
    }

}
