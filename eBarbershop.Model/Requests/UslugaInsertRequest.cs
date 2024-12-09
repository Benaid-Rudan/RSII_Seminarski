using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class UslugaInsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Naziv ne smije ostati prazno polje")]
        public string Naziv { get; set; }
        public string Opis { get; set; }
        public decimal Cijena { get; set; }
    }
}
