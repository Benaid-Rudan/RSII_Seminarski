using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public  class Uloga
{
    public int UlogaId { get; set; }

    public string Naziv { get; set; } = null!;

    public virtual ICollection<KorisnikUloga> KorisnikUlogas { get; set; } = new List<KorisnikUloga>();
}
