using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.SearchObjects
{
    public class TerminSearchObject : BaseSearchObject
    {
        public int? KorisnikID { get; set; }
        public string? imePrezime { get; set; }
        public bool? IncludeKorisnik { get; set; }
        public bool? IncludeRezervacija { get; set; }

        public bool? isBooked { get; set; }
        public DateTime? Datum { get; set; }
        public DateTime? DatumOd { get; set; }
        public DateTime? DatumDo { get; set; }


    }
}

