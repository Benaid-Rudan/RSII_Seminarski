using System;

namespace eBarbershop.Model.SearchObjects
{
    public class ListaCekanjaSearchObject : BaseSearchObject
    {
        public int? KlijentId { get; set; }
        public int? FrizerId { get; set; }
        public int? UslugaId { get; set; }
        //public StatusCekanja? Status { get; set; }
        public DateTime? DatumOd { get; set; }
        public DateTime? DatumDo { get; set; }
        public bool? IncludeKlijent { get; set; }
        public bool? IncludeFrizer { get; set; }
        public bool? IncludeUsluga { get; set; }
        public bool SortByPrioritet { get; set; } = true;
        public bool SortByMLSkor { get; set; } = false;
    }
}