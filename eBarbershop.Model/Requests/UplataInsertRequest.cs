using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class UplataInsertRequest
    {
        public decimal Iznos { get; set; }
        public DateTime DatumUplate { get; set; }
        public string NacinUplate { get; set; } = null!;

        public int NarudzbaId { get; set; }
    }
}
