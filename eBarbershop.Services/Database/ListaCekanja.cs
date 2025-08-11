using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Services.Database
{
    public class ListaCekanja
    {
        [Key]
        public int ListaCekanjaId { get; set; }
        public int KlijentId { get; set; }
        public virtual Korisnik Klijent { get; set; }
        public int FrizerId { get; set; }
        public virtual Korisnik Frizer { get; set; }
        public int UslugaId { get; set; }
        public virtual Usluga Usluga { get; set; }
        public DateTime ZeljeniDatum { get; set; }
        public TimeSpan? ZeljenoVrijeme { get; set; }
        public int Prioritet { get; set; }
        public DateTime DatumPrijave { get; set; }
        public int Status { get; set; } // 1=Aktivna, 2=Notificirana, 3=Prihvacena, 4=Istekla, 5=Otkazana
        public DateTime? DatumNotifikacije { get; set; }
        public DateTime? DatumIsteka { get; set; }
        public string Napomena { get; set; }
        public double MLSkor { get; set; }
        public bool NotifikacijaPoslana { get; set; }
    }
}
