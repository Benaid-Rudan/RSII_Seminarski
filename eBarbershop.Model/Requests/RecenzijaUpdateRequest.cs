using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class RecenzijaUpdateRequest
    {
        [Required]
        public string Komentar { get; set; } = null!;

        [Required]
        public int Ocjena { get; set; }

        [Required]
        public DateTime Datum { get; set; }

        [Required]
        public int KorisnikId { get; set; }

        

    }
}
