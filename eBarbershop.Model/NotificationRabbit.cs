using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class NotificationRabbit
    {
        [Key]
        public int Id { get; set; }
        public string Title { get; set; } = null!;
        public string? Content { get; set; }
        public bool IsRead { get; set; } = false;
        public int UserId { get; set; }
        public Korisnik User { get; set; } = null!;
    }
}
