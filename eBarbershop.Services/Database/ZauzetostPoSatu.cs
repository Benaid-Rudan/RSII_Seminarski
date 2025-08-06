using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services.Database
{
    public class ZauzetostPoSatu
    {
        public int Id { get; set; }
        public string Sat { get; set; }  // primjer: "08:00", "14:00"
        public double Vrijednost { get; set; }

        public int PredvidjanjeId { get; set; }  // FK
        public PredvidjanjeZauzetosti Predvidjanje { get; set; }
    }

}
