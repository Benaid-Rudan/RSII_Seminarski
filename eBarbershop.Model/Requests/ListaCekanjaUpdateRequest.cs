using System;
using System.ComponentModel.DataAnnotations;

namespace eBarbershop.Model.Requests
{
    public class ListaCekanjaUpdateRequest
    {
        [Required]
        public DateTime ZeljeniDatum { get; set; }

        public TimeSpan? ZeljenoVrijeme { get; set; }

        [MaxLength(500)]
        public string Napomena { get; set; }

        [Required]
        public StatusCekanja Status { get; set; }
    }
}