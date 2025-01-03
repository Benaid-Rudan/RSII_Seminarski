using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model.Requests
{
    public class KorisniciInsertRequest
    {
        public string Ime { get; set; }
        public string Prezime { get; set; }
        public string Email { get; set; }
        public string Username { get; set; }

        public string Password { get; set; }
        public string PasswordPotvrda { get; set; }
        public string Slika { get; set; }

        public int GradId { get; set; }

        public List<int> UlogeID { get; set; } = new List<int>();
    }
}
