using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class NotifikacijaListeCekanja
    {
        public int NotifikacijaId { get; set; }
        public int ListaCekanjaId { get; set; }
        public ListaCekanja ListaCekanja { get; set; }
        public int TerminId { get; set; }
        public Termin Termin { get; set; }
        public DateTime DatumNotifikacije { get; set; }
        public DateTime DatumIsteka { get; set; }
        public bool Odgovoreno { get; set; }
        public bool Prihvaceno { get; set; }
        public string PorukaNofitikacije { get; set; }
    }
}
