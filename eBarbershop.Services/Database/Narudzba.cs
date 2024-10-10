using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public partial class Narudzba
{
    public int NarudzbaId { get; set; }

    public DateTime Datum { get; set; }

    public decimal UkupnaCijena { get; set; }

    public int KorisnikId { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual ICollection<NarudzbaProizvodi> NarudzbaProizvodis { get; set; } = new List<NarudzbaProizvodi>();

    public virtual ICollection<Uplatum> Uplata { get; set; } = new List<Uplatum>();
}
