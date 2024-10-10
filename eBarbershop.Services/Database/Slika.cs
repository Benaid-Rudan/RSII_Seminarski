using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public partial class Slika
{
    public int SlikaId { get; set; }

    public string Url { get; set; } = null!;

    public int? ProizvodId { get; set; }

    public int? NovostId { get; set; }

    public virtual Novost? Novost { get; set; }

    public virtual Proizvod? Proizvod { get; set; }
}
