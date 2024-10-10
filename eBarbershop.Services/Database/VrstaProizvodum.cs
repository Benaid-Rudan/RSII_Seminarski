using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public partial class VrstaProizvodum
{
    public int VrstaProizvodaId { get; set; }

    public string Naziv { get; set; } = null!;

    public virtual ICollection<Proizvod> Proizvods { get; set; } = new List<Proizvod>();
}
