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
        public int? KlijentId { get; set; }

        public string? imePrezimeKlijenta { get; set; }
        public string? imePrezimeFrizera { get; set; }

        public DateTime? datumRezervacije { get; set; }

        public DateTime? DatumRezervacijeBezVremena
        {
            get { return datumRezervacije?.Date; } 
            set { datumRezervacije = value?.Date; } 
        }
        public DateTime? DatumOd { get; set; }
        public DateTime? DatumDo { get; set; }
        public bool? IncludeKorisnik { get; set; }
        public bool? IncludeKlijent { get; set; }

        public bool? IncludeUsluga { get; set; }
        public string? Usluga { get; set; }
    }
}

