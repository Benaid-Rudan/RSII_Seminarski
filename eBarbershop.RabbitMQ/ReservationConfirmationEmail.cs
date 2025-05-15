using RabbitMQ;
using System.Net.Mail;

namespace eBarbershop.RabbitMQ
{
    public class ReservationConfirmedEmail : MailObjekat
    {
        public ReservationConfirmedEmail(string email, string barberName, DateTime date, string serviceName)
        {
            mailAdresa = email;
            subject = "Potvrda rezervacije";
            poruka = $@"
            <h1>Hvala na rezervaciji!</h1>
            <p>Vaša rezervacija kod {barberName} za uslugu {serviceName} je potvrđena.</p>
            <p>Datum i vrijeme: {date.ToString("dd.MM.yyyy HH:mm")}</p>
            <p>Lijep pozdrav,<br/>eBarbershop tim</p>
        ";
        }
    }
}
