    using System;
    using System.Collections.Generic;
    using System.Text.Json.Serialization;

    namespace eBarbershop.Services.Database;

    public  class VrstaProizvodum
    {
        public int VrstaProizvodaId { get; set; }

        public string Naziv { get; set; } = null!;
        public virtual ICollection<Proizvod> Proizvods { get; set; } = new List<Proizvod>();
    }
