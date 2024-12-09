using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public  class Proizvod
{
    public int ProizvodId { get; set; }

    public string Naziv { get; set; } = null!;

    public string Opis { get; set; } = null!;

    public decimal Cijena { get; set; }

    public int Zalihe { get; set; }

    public int VrstaProizvodaId { get; set; }

    public virtual ICollection<NarudzbaProizvodi> NarudzbaProizvodis { get; set; } = new List<NarudzbaProizvodi>();

    public virtual ICollection<Recenzija> Recenzijas { get; set; } = new List<Recenzija>();

    public virtual ICollection<Slika> Slikas { get; set; } = new List<Slika>();

    public virtual VrstaProizvodum VrstaProizvoda { get; set; } = null!;
}
