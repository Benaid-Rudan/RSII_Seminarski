using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class KorisniciUpdateRequest
    {
        [Required]
        public string Ime { get; set; }
        [Required]
        public string Prezime { get; set; }
        [Required]
        public string Email { get; set; }
        [Required]
        public string Username { get; set; }

        
        public string? Password { get; set; }
        
        public string? PasswordPotvrda { get; set; }
        [Required]
        public string Slika { get; set; }

        [Required]
        public int GradId { get; set; }
        [Required]

        public List<int> UlogeID { get; set; } = new List<int>();
    }
}
