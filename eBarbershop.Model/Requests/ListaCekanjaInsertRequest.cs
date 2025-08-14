using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eBarbershop.Model.ValidationAttributes;

namespace eBarbershop.Model.Requests
{
    public class ListaCekanjaInsertRequest
    {
        [Required]
        public int FrizerId { get; set; }
        [Required]
        public int KlijentId { get; set; }
        [Required]
        public int UslugaId { get; set; }

        [Required]
        [FutureDate(ErrorMessage = "Željeni datum mora biti danas ili u budućnosti")]
        public DateTime ZeljeniDatum { get; set; }

        [BusinessHours(ErrorMessage = "Željeno vrijeme mora biti u radnom vremenu (08:00 - 20:00)")]
        public string ZeljenoVrijeme { get; set; }  // promijenjeno iz TimeSpan? u string

        [Range(1, 30, ErrorMessage = "Broj dana do isteka mora biti između 1 i 30")]
        public int DaniDoIsteka { get; set; } = 7;

        [MaxLength(500)]
        public string Napomena { get; set; }

        // Metoda ili property za parsiranje ZeljenoVrijeme u TimeSpan?
        //public TimeSpan? ParsedZeljenoVrijeme
        //{
        //    get
        //    {
        //        if (TimeSpan.TryParse(ZeljenoVrijeme, out var ts))
        //            return ts;
        //        return null;
        //    }
        //}
    }
}
