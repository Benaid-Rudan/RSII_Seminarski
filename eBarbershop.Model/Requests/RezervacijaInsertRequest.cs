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
        public int KorisnikId { get; set; } // This remains as the barber/employee ID

        [Required]
        public int UslugaId { get; set; }

        // Optionally add KupacId - will be overridden with logged-in user ID
        public int? KupacId { get; set; }
    }
}
