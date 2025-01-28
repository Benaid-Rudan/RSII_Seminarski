using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.SearchObjects
{
    public class RezervacijaSearchObject : BaseSearchObject
    {
        public int? KorisnikID { get; set; }
        public DateTime? DatumOd { get; set; }
        public DateTime? DatumDo { get; set; }
        public bool? IncludeKorisnik { get; set; }
        public bool? IncludeUsluga { get; set; }
    }
}

