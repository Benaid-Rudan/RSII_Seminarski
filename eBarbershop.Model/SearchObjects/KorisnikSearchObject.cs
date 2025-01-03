using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.SearchObjects
{
    public class KorisnikSearchObject : BaseSearchObject
    {
        public string? Ime { get; set; }
        public string? Prezime { get; set; }
        public string? Username { get; set; }
        public bool? IsUlogeIncluded { get; set; }
    }
}
