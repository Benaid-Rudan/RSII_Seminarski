using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public partial class Usluga
{
    public int UslugaId { get; set; }

    public string Naziv { get; set; } = null!;

    public string Opis { get; set; } = null!;

    public decimal Cijena { get; set; }

    public virtual ICollection<Recenzija> Recenzijas { get; set; } = new List<Recenzija>();

    public virtual ICollection<Rezervacija> Rezervacijas { get; set; } = new List<Rezervacija>();
}
