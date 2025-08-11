using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class WaitingListMLModel
    {
        public float KlijentId { get; set; }
        public float FrizerId { get; set; }
        public float UslugaId { get; set; }
        public float DanUNedelji { get; set; }
        public float SatUDanu { get; set; }
        public float TrenutnaZauzetost { get; set; }
        public float BrojPrethodnihRezervacija { get; set; }
        public float ProsjekOcjena { get; set; }
        public float DaniDoZeljenogTermina { get; set; }
        public float SezonalnostFaktor { get; set; }
        public float Label { get; set; } // Vjerojatnost da će klijent prihvatiti termin (0-1)
    }
}