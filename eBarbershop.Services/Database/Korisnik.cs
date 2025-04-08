using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public  class Korisnik
{
    public int KorisnikId { get; set; }

    public string Ime { get; set; } = null!;

    public string Prezime { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string Username { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public string PasswordSalt { get; set; } = null!;

    public int GradId { get; set; }
    public string Slika { get; set; }

    public virtual Grad Grad { get; set; } = null!;

    public virtual ICollection<KorisnikUloga> KorisnikUlogas { get; set; } = new List<KorisnikUloga>();

    public virtual ICollection<Narudzba> Narudzbas { get; set; } = new List<Narudzba>();

    public virtual ICollection<Recenzija> Recenzijas { get; set; } = new List<Recenzija>();
    public virtual ICollection<Rezervacija> RezervacijeKaoKlijent { get; set; }

    public virtual ICollection<Rezervacija> RezervacijeKaoFrizer { get; set; } = new List<Rezervacija>();
}
