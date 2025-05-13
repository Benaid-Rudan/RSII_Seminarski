using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace RabbitMQ
{
    public class MailSending
    {
        public static void posaljiMail(MailObjekat obj)
        {
            string serverAddress = Environment.GetEnvironmentVariable("SERVER_ADDRESS") ?? "smtp.gmail.com";
            string mailSender = Environment.GetEnvironmentVariable("MAIL_SENDER") ?? "emektebmail@gmail.com";
            string mailPass = Environment.GetEnvironmentVariable("MAIL_PASS") ?? "dkbehufjdusohlpw";
            int port = int.Parse(Environment.GetEnvironmentVariable("MAIL_PORT") ?? "587");

            string content = $"<p>{obj.poruka}</p>";
            string subject = obj.subject;


            var message = new MailMessage()
            {
                From = new MailAddress(mailSender),
                To = { new MailAddress(obj.mailAdresa) },
                Subject = subject,
                Body = content,
                IsBodyHtml = true
            };

            var smtpClient = new SmtpClient(serverAddress, port)
            {
                Credentials = new NetworkCredential(mailSender, mailPass),
                EnableSsl = true
            };

            try
            {
                Console.WriteLine("ADDRESS: " + serverAddress + "| SENDER: " + mailSender + "| PASS: " + mailPass + "| PORT: " + port.ToString());
                smtpClient.Send(message);
                Console.WriteLine("Mail sent");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: " + ex?.Message);
            }
        }
    }
}
