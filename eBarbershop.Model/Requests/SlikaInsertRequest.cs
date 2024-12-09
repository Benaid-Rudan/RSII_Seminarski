using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class SlikaInsertRequest
    {

        public string Url { get; set; }
        public int? ProizvodId { get; set; }
        public int? NovostId { get; set; }
    }
}
