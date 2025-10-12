using Microsoft.EntityFrameworkCore;
using System;
using System.Security.Cryptography;

namespace eBarbershop.Services.Database
{
    public static class DbSeed
    {
        public static void Seed(ModelBuilder modelBuilder)
        {
            // DRŽAVE
            modelBuilder.Entity<Drzava>().HasData(
                new Drzava { DrzavaId = 1, Naziv = "Bosna i Hercegovina" },
                new Drzava { DrzavaId = 2, Naziv = "Hrvatska" },
                new Drzava { DrzavaId = 3, Naziv = "Srbija" },
                new Drzava { DrzavaId = 4, Naziv = "Crna Gora" },
                new Drzava { DrzavaId = 5, Naziv = "Slovenija" }
            );

            // GRADOVI (DODANO: DrzavaId)
            modelBuilder.Entity<Grad>().HasData(
                new Grad { GradId = 1, Naziv = "Sarajevo", DrzavaId = 1 },
                new Grad { GradId = 2, Naziv = "Mostar", DrzavaId = 1 },
                new Grad { GradId = 3, Naziv = "Zagreb", DrzavaId = 2 },
                new Grad { GradId = 4, Naziv = "Split", DrzavaId = 2 },
                new Grad { GradId = 5, Naziv = "Beograd", DrzavaId = 3 },
                new Grad { GradId = 6, Naziv = "Novi Sad", DrzavaId = 3 }
            );

            // ULOGE
            modelBuilder.Entity<Uloga>().HasData(
                new Uloga { UlogaId = 1, Naziv = "Admin" },
                new Uloga { UlogaId = 2, Naziv = "Frizer" },
                new Uloga { UlogaId = 3, Naziv = "Klijent" }
            );
            var adminSalt = GenerateSalt();
            var klijentSalt = GenerateSalt();
            var frizerSalt = GenerateSalt();
            // KORISNICI
            modelBuilder.Entity<Korisnik>().HasData(
                new Korisnik
                {
                    KorisnikId = 1,
                    Ime = "Admin",
                    Prezime = "Admin",
                    Email = "admin@ebarbershop.com",
                    Username = "admin",
                    PasswordHash = GenerateHash(adminSalt, "admin123"),
                    PasswordSalt = adminSalt,
                    Slika = "https://cdn-icons-png.flaticon.com/512/2942/2942813.png",
                    GradId = 1
                },
                new Korisnik
                {
                    KorisnikId = 2,
                    Ime = "Frizer",
                    Prezime = "Frizer",
                    Email = "frizer@ebarbershop.com",
                    Username = "frizer",
                    PasswordHash = GenerateHash(frizerSalt, "frizer123"),
                    PasswordSalt = frizerSalt,
                    Slika = "https://spng.pngfind.com/pngs/s/314-3146924_barber-shop-logo-png-barber-shop-vector-png.png",
                    GradId = 1
                },
                new Korisnik
                {
                    KorisnikId = 3,
                    Ime = "Klijent",
                    Prezime = "Klijent",
                    Email = "klijent@email.com",
                    Username = "klijent",
                    PasswordHash = GenerateHash(klijentSalt, "klijent123"),
                    PasswordSalt = klijentSalt,
                    Slika = "https://static.vecteezy.com/system/resources/previews/019/879/186/non_2x/user-icon-on-transparent-background-free-png.png",
                    GradId = 2
                }
            );

            // NOVOSTI
            modelBuilder.Entity<Novost>().HasData(
                new Novost
                {
                    NovostId = 1,
                    Naslov = "Dobrodošli u eBarbershop",
                    Sadrzaj = "Radujemo se vašim posjetama u našem novom salonu!",
                    DatumObjave = DateTime.Parse("2025-05-06T22:50:49.650"),
                    Slika = "https://meroscut.com/cdn/shop/files/cfb85b4bf155ff5423d0d78816c00ec5.jpg?v=1712334723&width=1445"
                },
                new Novost
                {
                    NovostId = 2,
                    Naslov = "Nova linija proizvoda",
                    Sadrzaj = "Uveli smo nove profesionalne proizvode za njegu kose i brade",
                    DatumObjave = DateTime.Parse("2025-05-11T22:50:49.650"),
                    Slika = "https://parspng.com/wp-content/uploads/2023/04/Barbershopbeautysalonpng.parspng.com-13.png"
                }
            );

            // VRSTE PROIZVODA
            modelBuilder.Entity<VrstaProizvoda>().HasData(
                new VrstaProizvoda { VrstaProizvodaId = 1, Naziv = "Šamponi" },
                new VrstaProizvoda { VrstaProizvodaId = 2, Naziv = "Krema za brijanje" },
                new VrstaProizvoda { VrstaProizvodaId = 3, Naziv = "Gel za kosu" },
                new VrstaProizvoda { VrstaProizvodaId = 4, Naziv = "Ulja za bradu" }
            );

            // PROIZVODI
            modelBuilder.Entity<Proizvod>().HasData(
                new Proizvod
                {
                    ProizvodId = 1,
                    Naziv = "Šampon za muškarce",
                    Opis = "Profesionalni šampon za mušku kosu",
                    Cijena = 16m,
                    Zalihe = 50,
                    Slika = "https://www.biramzdravlje.hr/storage/upload/products/Pantogar-sampon-protiv-opadanja-kose-za-muskarce_133819.png",
                    VrstaProizvodaId = 1
                },
                new Proizvod
                {
                    ProizvodId = 2,
                    Naziv = "Krema za brijanje Classic",
                    Opis = "Krema za glatko i ugodno brijanje",
                    Cijena = 12.5m,
                    Zalihe = 30,
                    Slika = "https://www.just.hr/wp-content/uploads/2020/08/just-proizvodi-za-muskarce-gel-za-brijanje-819x1024.png",
                    VrstaProizvodaId = 2
                },
                new Proizvod
                {
                    ProizvodId = 3,
                    Naziv = "Gel za kosu Strong Hold",
                    Opis = "Gel za fiksiranje frizure",
                    Cijena = 9m,
                    Zalihe = 40,
                    Slika = "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80",
                    VrstaProizvodaId = 3
                },
                new Proizvod
                {
                    ProizvodId = 4,
                    Naziv = "Šampon protiv peruti",
                    Opis = "Efikasan šampon za uklanjanje peruti",
                    Cijena = 14.9m,
                    Zalihe = 35,
                    Slika = "https://media.dm-static.com/images/f_auto,q_auto,c_fit,h_1200,w_1200/v1744973382/products/pim/3337871331290-010191/vichy-dercos-anti-dandruff-sampon-protiv-peruti",
                    VrstaProizvodaId = 1
                },
                new Proizvod
                {
                    ProizvodId = 5,
                    Naziv = "Prirodno ulje za bradu",
                    Opis = "Ulje na bazi argana i jojobe za meku i zdravu bradu",
                    Cijena = 18m,
                    Zalihe = 25,
                    Slika = "https://www.tinktura.com/slike/male/beard-stache-oil-41136-02140007.png",
                    VrstaProizvodaId = 4
                }
            );

            // USLUGE
            modelBuilder.Entity<Usluga>().HasData(
                new Usluga { UslugaId = 1, Naziv = "Šišanje", Opis = "Kompletno šišanje kose", Cijena = 15m },
                new Usluga { UslugaId = 2, Naziv = "Brijanje", Opis = "Brijanje mašinicom ili britvom", Cijena = 10m },
                new Usluga { UslugaId = 3, Naziv = "Šišanje i brijanje", Opis = "Kompletna usluga šišanja i brijanja", Cijena = 20m },
                new Usluga { UslugaId = 9, Naziv = "Uređivanje brade", Opis = "Moderna usluga uređivanje brade", Cijena = 7m }
            );

            // REZERVACIJE (5 kom, +7 dana; zadnja 13.10.2025. u 10:00)
            var r1 = new Rezervacija { RezervacijaId = 1001, DatumRezervacije = new DateTime(2025, 09, 15, 10, 0, 0), KorisnikId = 2, KlijentId = 3, UslugaId = 1 };
            var r2 = new Rezervacija { RezervacijaId = 1002, DatumRezervacije = new DateTime(2025, 09, 22, 10, 0, 0), KorisnikId = 2, KlijentId = 3, UslugaId = 2 };
            var r3 = new Rezervacija { RezervacijaId = 1003, DatumRezervacije = new DateTime(2025, 09, 29, 10, 0, 0), KorisnikId = 2, KlijentId = 3, UslugaId = 3 };
            var r4 = new Rezervacija { RezervacijaId = 1004, DatumRezervacije = new DateTime(2025, 10, 06, 10, 0, 0), KorisnikId = 2, KlijentId = 3, UslugaId = 9 };
            var r5 = new Rezervacija { RezervacijaId = 1005, DatumRezervacije = new DateTime(2025, 10, 13, 10, 0, 0), KorisnikId = 2, KlijentId = 3, UslugaId = 1 };

            modelBuilder.Entity<Rezervacija>().HasData(r1, r2, r3, r4, r5);

            // TERMINI – 1:1 s rezervacijama (koristimo KorisnikID kako ga tvoj model traži)
            modelBuilder.Entity<Termin>().HasData(
                new Termin { TerminId = 2001, Vrijeme = r1.DatumRezervacije, KorisnikID = r1.KorisnikId, KlijentId = r1.KlijentId, RezervacijaId = r1.RezervacijaId, isBooked = true },
                new Termin { TerminId = 2002, Vrijeme = r2.DatumRezervacije, KorisnikID = r2.KorisnikId, KlijentId = r2.KlijentId, RezervacijaId = r2.RezervacijaId, isBooked = true },
                new Termin { TerminId = 2003, Vrijeme = r3.DatumRezervacije, KorisnikID = r3.KorisnikId, KlijentId = r3.KlijentId, RezervacijaId = r3.RezervacijaId, isBooked = true },
                new Termin { TerminId = 2004, Vrijeme = r4.DatumRezervacije, KorisnikID = r4.KorisnikId, KlijentId = r4.KlijentId, RezervacijaId = r4.RezervacijaId, isBooked = true },
                new Termin { TerminId = 2005, Vrijeme = r5.DatumRezervacije, KorisnikID = r5.KorisnikId, KlijentId = r5.KlijentId, RezervacijaId = r5.RezervacijaId, isBooked = true }
            );
        }
    public static string GenerateSalt()
    {
        var provider = new RNGCryptoServiceProvider();
        var byteArray = new byte[16];
        provider.GetBytes(byteArray);
        return Convert.ToBase64String(byteArray);
    }
    public static string GenerateHash(string salt, string password)
    {
        byte[] src = Convert.FromBase64String(salt);
        byte[] bytes = System.Text.Encoding.Unicode.GetBytes(password);
        byte[] dst = new byte[src.Length + bytes.Length];

        System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
        System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

        HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
        byte[] inArray = algorithm.ComputeHash(dst);
        return Convert.ToBase64String(inArray);
    }
    }

}
