using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.SearchObjects
{
    public class ProizvodSearchObject : BaseSearchObject
    {
        public string? Naziv { get; set; }
        public string? Opis { get; set; }
        public int? VrstaProizvodaID { get; set; }
        public bool? IncludeVrstaProizvoda { get; set; }
    }
}
