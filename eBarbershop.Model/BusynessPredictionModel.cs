using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class BusynessPredictionModel
    {
       public float BarberId { get; set; }
       public float DayOfWeek { get; set; }
       public float TimeSlot { get; set; }
       public float Month { get; set; }
       public float IsHoliday { get; set; }
       public float Label { get; set; } // busy percentage
    }
}
