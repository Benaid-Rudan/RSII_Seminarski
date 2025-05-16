using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class TerminInsertRequest
    {
        [Required]
        public DateTime Vrijeme { get; set; }
        [Required]
        public int RezervacijaId { get; set; }
        [Required]
        public int KorisnikID { get; set; }
        [Required]
        public int KlijentId { get; set; }
    }
}
