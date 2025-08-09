using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace eBarbershop.Services.Database
{
    public class PredvidjanjeZauzetosti
    {
        [Key] 
        public int PredvidjanjeId { get; set; }
        public DateTime Datum { get; set; }
        public int KorisnikId { get; set; }

        [JsonIgnore]
        public ICollection<ZauzetostPoSatu> ZauzetostPoSatima { get; set; } = new List<ZauzetostPoSatu>();
        public double UkupnaZauzetost { get; set; }
        public bool IsDefaultPrediction { get; set; }
        public List<string> PreporuceniTermini { get; set; }
    }

}
