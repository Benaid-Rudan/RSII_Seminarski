using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public partial class Rezervacija
{
    public int RezervacijaId { get; set; }

    public DateTime DatumRezervacije { get; set; }

    public DateTime Termin { get; set; }

    public int KorisnikId { get; set; }

    public int UslugaId { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual ICollection<Termin> Termins { get; set; } = new List<Termin>();

    public virtual Usluga Usluga { get; set; } = null!;
}
