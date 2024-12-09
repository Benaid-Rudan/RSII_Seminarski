using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class Termin
    {
        public int TerminId { get; set; }

        public DateTime Vrijeme { get; set; }

        public int RezervacijaId { get; set; }
        public Rezervacija Rezervacija { get; set; }
    }

}
