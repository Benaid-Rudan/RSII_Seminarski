using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public  class KorisnikUloga
{
    public int KorisnikUlogaId { get; set; }

    public int KorisnikId { get; set; }

    public int UlogaId { get; set; }

    public DateTime DatumDodjele { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual Uloga Uloga { get; set; } = null!;
}
