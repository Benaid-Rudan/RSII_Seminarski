using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class RezervacijaInsertRequest
    {
        public DateTime DatumRezervacije { get; set; }
        public DateTime Termin { get; set; }

        public int KorisnikId { get; set; }
        public int UslugaId { get; set; }
    }
}
