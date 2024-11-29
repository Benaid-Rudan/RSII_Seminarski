using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.SearchObjects
{
    public class RecenzijaSearchObject : BaseSearchObject
    {
        public int? UslugaId { get; set; }

        public int? ProizvodId { get; set; }
    }
}

