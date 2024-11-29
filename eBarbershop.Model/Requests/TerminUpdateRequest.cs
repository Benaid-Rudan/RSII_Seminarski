using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class TerminUpdateRequest
    {
        public DateTime Vrijeme { get; set; }

        public int RezervacijaId { get; set; }

    }
}
