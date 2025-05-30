﻿using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public  class Recenzija
{
    public int RecenzijaId { get; set; }

    public string Komentar { get; set; } = null!;

    public int Ocjena { get; set; }

    public DateTime Datum { get; set; }

    public int KorisnikId { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    
}
