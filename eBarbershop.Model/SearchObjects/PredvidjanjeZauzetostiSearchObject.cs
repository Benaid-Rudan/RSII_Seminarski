using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.SearchObjects
{
    public class PredvidjanjeZauzetostiSearchObject : BaseSearchObject
    {
        public int? KorisnikId { get; set; }
        public DateTime? Datum { get; set; }
    }
}
