using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public partial class Grad
{
    public int GradId { get; set; }

    public string Naziv { get; set; } = null!;

    public int DrzavaId { get; set; }

    public virtual Drzava Drzava { get; set; } = null!;

    public virtual ICollection<Korisnik> Korisniks { get; set; } = new List<Korisnik>();
}
