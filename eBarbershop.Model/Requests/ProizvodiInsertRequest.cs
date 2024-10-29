using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class ProizvodiInsertRequest
    {
        public string Naziv { get; set; }
        public string Opis { get; set; }
        public decimal Cijena { get; set; }

        public int Zalihe { get; set; }
        public int VrstaProizvodaId { get; set; }

    }
}
