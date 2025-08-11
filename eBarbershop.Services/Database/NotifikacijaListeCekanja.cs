using System;
using System.ComponentModel.DataAnnotations;

namespace eBarbershop.Services.Database
{
    public class NotifikacijaListeCekanja
    {
        [Key]
        public int NotifikacijaId { get; set; }
        public int ListaCekanjaId { get; set; }
        public virtual ListaCekanja ListaCekanja { get; set; }
        public int TerminId { get; set; }
        public virtual Termin Termin { get; set; }
        public DateTime DatumNotifikacije { get; set; }
        public DateTime DatumIsteka { get; set; }
        public bool Odgovoreno { get; set; }
        public bool Prihvaceno { get; set; }
        public string PorukaNofitikacije { get; set; }
    }
}