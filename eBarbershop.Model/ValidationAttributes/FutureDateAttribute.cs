using System;
using System.ComponentModel.DataAnnotations;

namespace eBarbershop.Model.ValidationAttributes
{
    public class FutureDateAttribute : ValidationAttribute
    {
        public override bool IsValid(object value)
        {
            if (value is DateTime dateTime)
            {
                return dateTime.Date >= DateTime.Today;
            }
            return false;
        }

        public override string FormatErrorMessage(string name)
        {
            return $"{name} mora biti danas ili u budućnosti.";
        }
    }

    public class BusinessHoursAttribute : ValidationAttribute
    {
        public override bool IsValid(object value)
        {
            if (value is TimeSpan time)
            {
                return time >= new TimeSpan(8, 0, 0) && time <= new TimeSpan(20, 0, 0);
            }
            return true; // null values are handled by Required attribute
        }

        public override string FormatErrorMessage(string name)
        {
            return $"{name} mora biti između 08:00 i 20:00.";
        }
    }
}