//using System;
//using System.Threading.Tasks;
//using eBarbershop.Model;
//using Microsoft.Extensions.Logging;

//namespace eBarbershop.Services
//{
//    public interface IWaitingListNotificationService
//    {
//        Task SendWaitingListJoinedNotification(ListaCekanja stavka, Korisnik klijent, Korisnik frizer, Usluga usluga);
//        Task SendSlotAvailableNotification(ListaCekanja stavka, Termin termin, Korisnik klijent, Korisnik frizer);
//        Task SendReminderNotification(NotifikacijaListeCekanja notifikacija);
//        Task SendWaitingListUpdatedNotification(ListaCekanja stavka, string reason);
//    }

//    public class WaitingListNotificationService : IWaitingListNotificationService
//    {
//        private readonly IMailService _mailService;
//        private readonly ILogger<WaitingListNotificationService> _logger;

//        public WaitingListNotificationService(IMailService mailService, ILogger<WaitingListNotificationService> logger)
//        {
//            _mailService = mailService;
//            _logger = logger;
//        }

//        public async Task SendWaitingListJoinedNotification(ListaCekanja stavka, Korisnik klijent, Korisnik frizer, Usluga usluga)
//        {
//            if (string.IsNullOrEmpty(klijent.Email)) return;

//            var prioritetText = stavka.Prioritet switch
//            {
//                >= 80 => "Vrlo visok",
//                >= 60 => "Visok",
//                >= 40 => "Srednji",
//                >= 20 => "Nizak",
//                _ => "Vrlo nizak"
//            };

//            var mailObject = new MailObject
//            {
//                mailAdresa = klijent.Email,
//                subject = "✅ Uspješno dodani na listu čekanja - eBarbershop",
//                poruka = $@"
//                    <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
//                        <h2 style='color: #2c5aa0;'>Poštovani {klijent.Ime},</h2>
                        
//                        <p>Uspješno ste dodani na listu čekanja! 🎉</p>
                        
//                        <div style='background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;'>
//                            <h3 style='margin-top: 0; color: #495057;'>Detalji zahtjeva:</h3>
//                            <p><strong>👨‍💼 Frizer:</strong> {frizer.Ime} {frizer.Prezime}</p>
//                            <p><strong>✂️ Usluga:</strong> {usluga.Naziv}</p>
//                            <p><strong>📅 Željeni datum:</strong> {stavka.ZeljeniDatum:dd.MM.yyyy}</p>
//                            <p><strong>⏰ Željeno vrijeme:</strong> {(stavka.ZeljenoVrijeme?.ToString(@"hh\:mm") ?? "Bilo koje")}</p>
//                            <p><strong>🏆 Vaš prioritet:</strong> {stavka.Prioritet}/100 ({prioritetText})</p>
//                            <p><strong>📊 ML Score:</strong> {stavka.MLSkor:P1}</p>
//                        </div>
                        
//                        <div style='background: #d1ecf1; padding: 15px; border-radius: 8px; border-left: 4px solid #bee5eb;'>
//                            <h4 style='margin-top: 0; color: #0c5460;'>Šta dalje?</h4>
//                            <ul style='color: #0c5460;'>
//                                <li>Obavijestit ćemo vas čim se oslobodi odgovarajući termin</li>
//                                <li>Imat ćete 2 sata da potvrdite rezervaciju</li>
//                                <li>Možete pratiti status putem aplikacije</li>
//                            </ul>
//                        </div>
                        
//                        <p style='margin-top: 30px;'>Hvala što koristite eBarbershop! 💈</p>
                        
//                        <hr style='margin: 30px 0; border: none; border-top: 1px solid #dee2e6;'>
//                        <p style='font-size: 12px; color: #6c757d;'>
//                            Ova poruka je automatski generisana. Molimo ne odgovarajte na ovaj email.
//                        </p>
//                    </div>"
//            };

//            await _mailService.startConnection(mailObject);
//            _logger.LogInformation($"Poslana notifikacija o pridruživanju listi čekanja korisniku {klijent.KorisnikId}");
//        }

//        public async Task SendSlotAvailableNotification(ListaCekanja stavka, Termin termin, Korisnik klijent, Korisnik frizer)
//        {
//            if (string.IsNullOrEmpty(klijent.Email)) return;

//            var mailObject = new MailObject
//            {
//                mailAdresa = klijent.Email,
//                subject = "🎉 DOSTUPAN JE TERMIN! - Potvrdite rezervaciju",
//                poruka = $@"
//                    <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
//                        <div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0;'>
//                            <h1 style='margin: 0; font-size: 28px;'>🎉 ODLIČAN JE TRENUTAK!</h1>
//                            <p style='margin: 10px 0 0 0; font-size: 18px;'>Dostupan je termin koji ste čekali!</p>
//                        </div>
                        
//                        <div style='background: white; padding: 30px; border: 1px solid #e9ecef; border-top: none;'>
//                            <h2 style='color: #2c5aa0; margin-top: 0;'>Detalji termina:</h2>
                            
//                            <div style='background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;'>
//                                <p style='margin: 5px 0;'><strong>👨‍💼 Frizer:</strong> {frizer.Ime} {frizer.Prezime}</p>
//                                <p style='margin: 5px 0;'><strong>📅 Datum:</strong> {termin.Vrijeme:dddd, dd.MM.yyyy}</p>
//                                <p style='margin: 5px 0;'><strong>⏰ Vrijeme:</strong> {termin.Vrijeme:HH:mm}h</p>
//                                <p style='margin: 5px 0;'><strong>✂️ Usluga:</strong> {stavka.Usluga.Naziv}</p>
//                                <p style='margin: 5px 0;'><strong>💰 Cijena:</strong> {stavka.Usluga.Cijena:C}</p>
//                            </div>
                            
//                            <div style='background: #fff3cd; padding: 20px; border-radius: 8px; border: 1px solid #ffeaa7; margin: 20px 0;'>
//                                <h3 style='margin-top: 0; color: #856404;'>⏰ VAŽNO - Ograničeno vrijeme!</h3>
//                                <p style='color: #856404; font-size: 16px; margin: 0;'>
//                                    Imate <strong>2 sata</strong> da potvrdite ovaj termin putem aplikacije.
//                                    Nakon toga će biti ponuđen drugima.
//                                </p>
//                            </div>
                            
//                            <div style='text-align: center; margin: 30px 0;'>
//                                <div style='background: #28a745; color: white; padding: 15px 30px; border-radius: 25px; display: inline-block; font-weight: bold; font-size: 16px;'>
//                                    📱 Prijavite se u aplikaciju i potvrdite!
//                                </div>
//                            </div>
                            
//                            <p style='text-align: center; margin-top: 30px; color: #6c757d;'>
//                                Hvala što koristite eBarbershop! 💈
//                            </p>
//                        </div>
                        
//                        <div style='background: #f8f9fa; padding: 15px; text-align: center; border-radius: 0 0 8px 8px;'>
//                            <p style='font-size: 12px; color: #6c757d; margin: 0;'>
//                                Ova poruka je automatski generisana. Molimo ne odgovarajte na ovaj email.
//                            </p>
//                        </div>
//                    </div>"
//            };

//            await _mailService.startConnection(mailObject);
//            _logger.LogInformation($"Poslana notifikacija o dostupnom terminu korisniku {klijent.KorisnikId}");
//        }

//        public async Task SendReminderNotification(NotifikacijaListeCekanja notifikacija)
//        {
//            var stavka = notifikacija.ListaCekanja;
//            var klijent = stavka.Klijent;

//            if (string.IsNullOrEmpty(klijent.Email)) return;

//            var preostaloVrijeme = notifikacija.DatumIsteka.Subtract(DateTime.Now);
//            var minutePreostalo = (int)preostaloVrijeme.TotalMinutes;

//            var mailObject = new MailObject
//            {
//                mailAdresa = klijent.Email,
//                subject = $"⏰ PODSJEĆANJE - {minutePreostalo} minuta do isteka!",
//                poruka = $@"
//                    <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
//                        <div style='background: #fd7e14; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;'>
//                            <h2 style='margin: 0;'>⏰ PODSJEĆANJE</h2>
//                            <p style='margin: 10px 0 0 0;'>Vaša rezervacija uskoro ističe!</p>
//                        </div>
                        
//                        <div style='background: white; padding: 20px; border: 1px solid #e9ecef; border-top: none; border-radius: 0 0 8px 8px;'>
//                            <p>Poštovani {klijent.Ime},</p>
                            
//                            <p>Podsjećamo vas da imate <strong>{minutePreostalo} minuta</strong> da potvrdite rezervaciju termina:</p>
                            
//                            <div style='background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 15px 0;'>
//                                <p><strong>Datum:</strong> {notifikacija.Termin.Vrijeme:dd.MM.yyyy}</p>
//                                <p><strong>Vrijeme:</strong> {notifikacija.Termin.Vrijeme:HH:mm}h</p>
//                            </div>
                            
//                            <div style='text-align: center; margin: 20px 0;'>
//                                <div style='background: #dc3545; color: white; padding: 10px 20px; border-radius: 20px; display: inline-block;'>
//                                    📱 Potvrdite SADA putem aplikacije!
//                                </div>
//                            </div>
//                        </div>
//                    </div>"
//            };

//            await _mailService.startConnection(mailObject);
//            _logger.LogInformation($"Poslano podsjećanje korisniku {klijent.KorisnikId}");
//        }

//        //public async Task SendWaitingListUpdatedNotification(ListaCekanja stavka, string reason)
//        //{
//        //    var klijent = stavka.Klijent;
//        //    if (string.IsNullOrEmpty(klijent.Email)) return;

//        //    //var statusText = stavka.Status switch
//        //    //{
//        //    //    StatusCekanja.Prihvacena => "✅ Prihvačena",
//        //    //    StatusCekanja.Istekla => "⏰ Istekla",
//        //    //    StatusCekanja.Otkazana => "❌ Otkazana",
//        //    //    _ => "📋 Ažurirana"
//        //    //};

//        //    var mailObject = new MailObject
//        //    {
//        //        mailAdresa = klijent.Email,
//        //        subject = $"Lista čekanja - Status ažuriran: {statusText}",
//        //        poruka = $@"
//        //            <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
//        //                <h2 style='color: #2c5aa0;'>Poštovani {klijent.Ime},</h2>
                        
//        //                <p>Status vaše liste čekanja je ažuriran:</p>
                        
//        //                <div style='background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;'>
//        //                    <p><strong>Novi status:</strong> {statusText}</p>
//        //                    <p><strong>Razlog:</strong> {reason}</p>
//        //                    <p><strong>Datum ažuriranja:</strong> {DateTime.Now:dd.MM.yyyy HH:mm}</p>
//        //                </div>
                        
//        //                <p>Za više detalja, molimo provjerite aplikaciju.</p>
                        
//        //                <p>Hvala što koristite eBarbershop! 💈</p>
//        //            </div>"
//        //    };

//        //    await _mailService.startConnection(mailObject);
//        //    _logger.LogInformation($"Poslana notifikacija o ažuriranju liste čekanja korisniku {klijent.KorisnikId}");
//        //}
//    }
//}