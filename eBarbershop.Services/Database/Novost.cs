using System;
using System.Collections.Generic;

namespace eBarbershop.Services.Database;

public  class Novost
{
    public int NovostId { get; set; }

    public string Naslov { get; set; } = null!;

    public string Sadrzaj { get; set; } = null!;

    public DateTime DatumObjave { get; set; }

    public string Slika { get; set; }
}
