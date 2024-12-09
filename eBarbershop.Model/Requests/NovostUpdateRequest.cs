using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class NovostUpdateRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Naslov ne smije ostati prazno polje")]
        public string Naslov { get; set; }
        [Required(AllowEmptyStrings = false, ErrorMessage = "Sadrzaj ne smije ostati prazno polje")]
        public string Sadrzaj { get; set; }
        [Required]
        public DateTime DatumObjave { get; set; }

    }
}
