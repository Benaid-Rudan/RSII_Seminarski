using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Novost
    {
        public int NovostId { get; set; }
        public string Naslov { get; set; }
        public string Sadrzaj { get; set; }
        public DateTime DatumObjave { get; set; }
        public string Slika { get; set; }

        // Moguća veza sa slikama
        //public ICollection<Slika> Slike { get; set; }
    }

}
