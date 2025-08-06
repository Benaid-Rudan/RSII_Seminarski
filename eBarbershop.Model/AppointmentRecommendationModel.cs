using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBarbershop.Model
{
    public class AppointmentRecommendationModel
    {
        public float ClientId { get; set; }
        public float BarberId { get; set; }
        public float ServiceId { get; set; }
        public float DayOfWeek { get; set; }
        public float TimeOfDay { get; set; }
        public float Frequency { get; set; }
        public float Label { get; set; } // 1 if accepted, 0 otherwise
    }
}
