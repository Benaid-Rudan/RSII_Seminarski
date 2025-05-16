using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

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

    public string Slika { get; set; }
    public bool IsDeleted { get; set; } = false;
    public virtual VrstaProizvoda VrstaProizvoda { get; set; } = null!;
}
