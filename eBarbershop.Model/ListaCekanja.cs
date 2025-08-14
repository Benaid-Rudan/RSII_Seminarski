using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class ListaCekanja
    {
        public int ListaCekanjaId { get; set; }
        public int KlijentId { get; set; }
        public Korisnik Klijent { get; set; }
        public int FrizerId { get; set; }
        public Korisnik Frizer { get; set; }
        public int UslugaId { get; set; }
        public Usluga Usluga { get; set; }
        public DateTime ZeljeniDatum { get; set; }
        public TimeSpan? ZeljenoVrijeme { get; set; } // null znači bilo koje vrijeme
        public int Prioritet { get; set; } // ML-generated priority score
        public DateTime DatumPrijave { get; set; }
        //public StatusCekanja Status { get; set; }
        public DateTime? DatumNotifikacije { get; set; }
        public DateTime? DatumIsteka { get; set; }
        public string Napomena { get; set; }
        public double MLSkor { get; set; } // Machine Learning confidence score
        public bool NotifikacijaPoslana { get; set; }
    }

    //public enum StatusCekanja
    //{
    //    Aktivna = 1,
    //    Notificirana = 2,
    //    Prihvacena = 3,
    //    Istekla = 4,
    //    Otkazana = 5
    //}
}
