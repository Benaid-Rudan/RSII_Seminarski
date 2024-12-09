using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public  class Usluga
{
    public int UslugaId { get; set; }

    public string Naziv { get; set; } = null!;

    public string Opis { get; set; } = null!;

    public decimal Cijena { get; set; }

    public virtual ICollection<Rezervacija> Rezervacijas { get; set; } = new List<Rezervacija>();
}
