using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class RezervacijaUpdateRequest
    {
        [Required]
        [JsonConverter(typeof(JsonDateTimeConverter))]
        public DateTime DatumRezervacije { get; set; }

        [Required]
        public int KorisnikId { get; set; } // Barber/employee ID

        [Required]
        public int UslugaId { get; set; }

        // Add the customer ID
        [Required]
        public int KupacId { get; set; }
    }
}
