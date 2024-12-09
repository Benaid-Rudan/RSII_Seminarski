using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class RecenzijaUpdateRequest
    {
        public string Komentar { get; set; } = null!;

        public int Ocjena { get; set; }

        public DateTime Datum { get; set; }

        public int KorisnikId { get; set; }

        //public int? UslugaId { get; set; }

        //public int? ProizvodId { get; set; }

    }
}
