using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Slika
    {
        public int SlikaId { get; set; }
        public string Url { get; set; }

        // Veza sa proizvodom ili novosti
        public int? ProizvodId { get; set; }
        public Proizvod Proizvod { get; set; }

        public int? NovostId { get; set; }
        public Novost Novost { get; set; }
    }

}
