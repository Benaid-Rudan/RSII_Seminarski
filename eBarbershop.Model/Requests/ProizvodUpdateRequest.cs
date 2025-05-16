using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class ProizvodUpdateRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Naziv ne smije ostati prazno polje")]
        public string Naziv { get; set; }
        [Required]
        public string Opis { get; set; }
        [Required(AllowEmptyStrings = false, ErrorMessage = "Opis ne smije ostati prazno polje")]
        public decimal Cijena { get; set; }
        [Required]
        public string Slika { get; set; }
        [Required]
        public int Zalihe { get; set; }
        [Required]
        public int VrstaProizvodaId { get; set; }

    }
}
