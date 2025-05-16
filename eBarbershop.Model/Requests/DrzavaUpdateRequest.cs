using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class DrzavaUpdateRequest
    {
        [Required]
        public string Naziv { get; set; }

    }
}
