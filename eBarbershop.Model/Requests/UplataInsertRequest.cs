using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class UplataInsertRequest
    {
        [Required]
        public decimal Iznos { get; set; }
        [Required]
        public DateTime DatumUplate { get; set; }
        [Required]
        public string NacinUplate { get; set; } = null!;

        [Required]
        public int NarudzbaId { get; set; }
    }
}
