using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public  class Uplatum
{
    public int UplataId { get; set; }

    public decimal Iznos { get; set; }

    public DateTime DatumUplate { get; set; }

    public string NacinUplate { get; set; } = null!;

    public int NarudzbaId { get; set; }

    public virtual Narudzba Narudzba { get; set; } = null!;
}
