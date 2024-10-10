using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public partial class NarudzbaProizvodi
{
    public int NarudzbaProizvodiId { get; set; }

    public int NarudzbaId { get; set; }

    public int ProizvodId { get; set; }

    public int Kolicina { get; set; }

    public decimal Cijena { get; set; }

    public virtual Narudzba Narudzba { get; set; } = null!;

    public virtual Proizvod Proizvod { get; set; } = null!;
}
