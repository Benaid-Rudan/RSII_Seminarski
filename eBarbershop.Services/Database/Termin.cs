using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public  class Termin
{
    public int TerminId { get; set; }

    public DateTime Vrijeme { get; set; }

    public int RezervacijaId { get; set; }

    public virtual Rezervacija Rezervacija { get; set; } = null!;
    public bool isBooked { get; set; }
}
