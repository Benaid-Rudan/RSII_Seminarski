using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class RecenzijaInsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Komentar ne smije ostati prazno polje")]
        public string Komentar { get; set; } = null!;
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ocjena ne smije ostati prazno polje")]

        public int Ocjena { get; set; }
        [Required]

        public DateTime Datum { get; set; }
        [Required]
        public int KorisnikId { get; set; }

        
    }
}
