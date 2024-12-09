using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class RezervacijaInsertRequest
    {
        [Required]
        public DateTime DatumRezervacije { get; set; }
        [Required]
        public DateTime Termin { get; set; }
        [Required]
        public int KorisnikId { get; set; }
        [Required] 
        public int UslugaId { get; set; }
    }
}
