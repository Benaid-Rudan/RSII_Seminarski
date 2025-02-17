using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;


namespace eBarbershop.Model.Requests
{
    public class RezervacijaInsertRequest
    {
        [Required]
        [JsonConverter(typeof(JsonDateTimeConverter))]
        public DateTime DatumRezervacije { get; set; }

        [Required]
        public int KorisnikId { get; set; }
        [Required] 
        public int UslugaId { get; set; }
    }
}
