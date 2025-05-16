using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;

namespace eBarbershop.Services.Database;

public  class Rezervacija
{
    public int RezervacijaId { get; set; }

    public DateTime DatumRezervacije { get; set; }


    public int KorisnikId { get; set; }
    public virtual Korisnik Korisnik { get; set; } = null!;

    public int KlijentId { get; set; }
    public virtual Korisnik Klijent { get; set; } = null!;


    public int UslugaId { get; set; }


    public virtual ICollection<Termin> Termins { get; set; } = new List<Termin>();

    public virtual Usluga Usluga { get; set; } = null!;

}
