using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class NarudzbaUpdateRequest
    {
        public DateTime Datum { get; set; }
        public decimal UkupnaCijena { get; set; }
        public int KorisnikId { get; set; }

    }
}
