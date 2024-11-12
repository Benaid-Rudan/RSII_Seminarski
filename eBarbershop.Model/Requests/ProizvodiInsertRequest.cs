using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class ProizvodiInsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Naziv ne smije ostati prazno polje")]
        public string Naziv { get; set; }
        public string Opis { get; set; }
        [Required]
        public decimal Cijena { get; set; }

        public int Zalihe { get; set; }
        public int VrstaProizvodaId { get; set; }

    }
}
