﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class NarudzbaInsertRequest
    {
        [Required]
        public DateTime Datum { get; set; }
        [Required]
        public decimal UkupnaCijena { get; set; }
        [Required]
        public int KorisnikId { get; set; }
        [Required]
        public List<NarudzbaProizvodiInsertRequest> ListaProizvoda { get; set; }
    }
}
