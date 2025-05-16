using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;
using System.Text;
using eBarbershop.Services.Database;

namespace eBarbershop.Services.Database;

public static class SeedDbInitializer
{
    public static void Seed(EBarbershop1Context context)
    {
        if (context.Drzava.Any())
        {
            return;
        }

        // Seed Countries
        var countries = new Drzava[]
        {
            new Drzava { Naziv = "Bosna i Hercegovina" },
            new Drzava { Naziv = "Hrvatska" },
            new Drzava { Naziv = "Srbija" },
            new Drzava { Naziv = "Crna Gora" },
            new Drzava { Naziv = "Slovenija" }
        };

        foreach (var c in countries)
        {
            context.Drzava.Add(c);
        }
        context.SaveChanges();

        // Seed Cities
        var cities = new Grad[]
        {
            new Grad { Naziv = "Sarajevo", DrzavaId = countries.Single(d => d.Naziv == "Bosna i Hercegovina").DrzavaId },
            new Grad { Naziv = "Mostar", DrzavaId = countries.Single(d => d.Naziv == "Bosna i Hercegovina").DrzavaId },
            new Grad { Naziv = "Zagreb", DrzavaId = countries.Single(d => d.Naziv == "Hrvatska").DrzavaId },
            new Grad { Naziv = "Split", DrzavaId = countries.Single(d => d.Naziv == "Hrvatska").DrzavaId },
            new Grad { Naziv = "Beograd", DrzavaId = countries.Single(d => d.Naziv == "Srbija").DrzavaId },
            new Grad { Naziv = "Novi Sad", DrzavaId = countries.Single(d => d.Naziv == "Srbija").DrzavaId }
        };

        foreach (var g in cities)
        {
            context.Grad.Add(g);
        }
        context.SaveChanges();

        // Seed Roles
        var roles = new Uloga[]
        {
            new Uloga { Naziv = "Admin" },
            new Uloga { Naziv = "Frizer" },
            new Uloga { Naziv = "Klijent" }
        };

        foreach (var r in roles)
        {
            context.Uloga.Add(r);
        }
        context.SaveChanges();

        // Seed Users
        var adminSalt = GenerateSalt();
        var frizerSalt = GenerateSalt();
        var klijentSalt = GenerateSalt();

        var users = new Korisnik[]
        {
            new Korisnik
            {
                Ime = "Admin",
                Prezime = "Admin",
                Email = "admin@ebarbershop.com",
                Username = "admin",
                PasswordHash = GenerateHash(adminSalt, "admin123"),
                PasswordSalt = adminSalt,
                GradId = cities.Single(g => g.Naziv == "Sarajevo").GradId,
                Slika = "https://cdn-icons-png.flaticon.com/512/2942/2942813.png"
            },
            new Korisnik
            {
                Ime = "Frizer",
                Prezime = "Frizer",
                Email = "frizer@ebarbershop.com",
                Username = "frizer",
                PasswordHash = GenerateHash(frizerSalt, "frizer123"),
                PasswordSalt = frizerSalt,
                GradId = cities.Single(g => g.Naziv == "Sarajevo").GradId,
                Slika = "https://spng.pngfind.com/pngs/s/314-3146924_barber-shop-logo-png-barber-shop-vector-png.png"
            },
            new Korisnik
            {
                Ime = "Klijent",
                Prezime = "Klijent",
                Email = "klijent@email.com",
                Username = "klijent",
                PasswordHash = GenerateHash(klijentSalt, "klijent123"),
                PasswordSalt = klijentSalt,
                GradId = cities.Single(g => g.Naziv == "Mostar").GradId,
                Slika = "https://static.vecteezy.com/system/resources/previews/019/879/186/non_2x/user-icon-on-transparent-background-free-png.png"
            }
        };

        foreach (var u in users)
        {
            context.Korisnik.Add(u);
        }
        context.SaveChanges();

        // Assign Roles to Users
        var userRoles = new KorisnikUloga[]
        {
            new KorisnikUloga
            {
                KorisnikId = users.Single(u => u.Username == "admin").KorisnikId,
                UlogaId = roles.Single(r => r.Naziv == "Admin").UlogaId,
                DatumDodjele = DateTime.Now
            },
            new KorisnikUloga
            {
                KorisnikId = users.Single(u => u.Username == "frizer").KorisnikId,
                UlogaId = roles.Single(r => r.Naziv == "Frizer").UlogaId,
                DatumDodjele = DateTime.Now
            },
            new KorisnikUloga
            {
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                UlogaId = roles.Single(r => r.Naziv == "Klijent").UlogaId,
                DatumDodjele = DateTime.Now
            }
        };

        foreach (var ur in userRoles)
        {
            context.KorisnikUloga.Add(ur);
        }
        context.SaveChanges();

        // Seed Product Types
        var productTypes = new VrstaProizvoda[]
        {
            new VrstaProizvoda { Naziv = "Šamponi" },
            new VrstaProizvoda { Naziv = "Krema za brijanje" },
            new VrstaProizvoda { Naziv = "Gel za kosu" },
            new VrstaProizvoda { Naziv = "Ulja za bradu" }
        };

        foreach (var pt in productTypes)
        {
            context.VrstaProizvoda.Add(pt);
        }
        context.SaveChanges();

        // Seed Products
        var products = new Proizvod[]
        {
            new Proizvod
            {
                Naziv = "Šampon za muškarce",
                Opis = "Profesionalni šampon za mušku kosu",
                Cijena = 16.00m,
                Zalihe = 50,
                VrstaProizvodaId = productTypes.Single(pt => pt.Naziv == "Šamponi").VrstaProizvodaId,
                Slika = "https://www.biramzdravlje.hr/storage/upload/products/Pantogar-sampon-protiv-opadanja-kose-za-muskarce_133819.png"
            },
            new Proizvod
            {
                Naziv = "Krema za brijanje Classic",
                Opis = "Krema za glatko i ugodno brijanje",
                Cijena = 12.50m,
                Zalihe = 30,
                VrstaProizvodaId = productTypes.Single(pt => pt.Naziv == "Krema za brijanje").VrstaProizvodaId,
                Slika = "https://www.just.hr/wp-content/uploads/2020/08/just-proizvodi-za-muskarce-gel-za-brijanje-819x1024.png"
            },
            new Proizvod
            {
                Naziv = "Gel za kosu Strong Hold",
                Opis = "Gel za fiksiranje frizure",
                Cijena = 9.00m,
                Zalihe = 40,
                VrstaProizvodaId = productTypes.Single(pt => pt.Naziv == "Gel za kosu").VrstaProizvodaId,
                Slika = "https://w7.pngwing.com/pngs/394/339/png-transparent-lotion-nivea-hair-styling-products-hairstyle-hair-gel-hair-gel.png"
            }
        };

        foreach (var p in products)
        {
            context.Proizvod.Add(p);
        }
        context.SaveChanges();

        var services = new Usluga[]
        {
            new Usluga
            {
                Naziv = "Šišanje",
                Opis = "Kompletno šišanje kose",
                Cijena = 15.00m
            },
            new Usluga
            {
                Naziv = "Brijanje",
                Opis = "Brijanje mašinicom ili britvom",
                Cijena = 10.00m
            },
            new Usluga
            {
                Naziv = "Šišanje i brijanje",
                Opis = "Kompletna usluga šišanja i brijanja",
                Cijena = 20.00m
            }
        };

        foreach (var s in services)
        {
            context.Usluga.Add(s);
        }
        context.SaveChanges();

        // Seed News
        var news = new Novost[]
        {
            new Novost
            {
                Naslov = "Dobrodošli u eBarbershop",
                Sadrzaj = "Radujemo se vašim posjetama u našem novom salonu!",
                DatumObjave = DateTime.Now.AddDays(-10),
                Slika = "https://png.pngtree.com/png-vector/20220818/ourmid/pngtree-barbershop-pole-decoration-png-image_6115703.png"
            },
            new Novost
            {
                Naslov = "Nova linija proizvoda",
                Sadrzaj = "Uveli smo nove profesionalne proizvode za njegu kose i brade",
                DatumObjave = DateTime.Now.AddDays(-5),
                Slika = "https://parspng.com/wp-content/uploads/2023/04/Barbershopbeautysalonpng.parspng.com-13.png"
            }
        };

        foreach (var n in news)
        {
            context.Novost.Add(n);
        }
        context.SaveChanges();

        var orders = new Narudzba[]
        {
            new Narudzba
            {
                Datum = DateTime.Now.AddDays(-3),
                UkupnaCijena = 34.00m,
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                NarudzbaProizvodis = new List<NarudzbaProizvodi>
                {
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Šampon za muškarce").ProizvodId,
                        Kolicina = 1
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Gel za kosu Strong Hold").ProizvodId,
                        Kolicina = 2
                    }
                }
            }
        };

        foreach (var o in orders)
        {
            context.Narudzba.Add(o);
        }
        context.SaveChanges();

        var payments = new Uplatum[]
        {
            new Uplatum
            {
                Iznos = 34.00m,
                DatumUplate = DateTime.Now.AddDays(-2),
                NacinUplate = "Gotovina",
                NarudzbaId = orders[0].NarudzbaId
            }
        };

        foreach (var p in payments)
        {
            context.Uplata.Add(p);
        }
        context.SaveChanges();

        var reviews = new Recenzija[]
        {
            new Recenzija
            {
                Komentar = "Odlična usluga, preporučujem!",
                Ocjena = 10,
                Datum = DateTime.Now.AddDays(-1),
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId
            }
        };

        foreach (var r in reviews)
        {
            context.Recenzija.Add(r);
        }
        context.SaveChanges();

        // Seed Appointments
        var appointments = new Rezervacija[]
        {
            new Rezervacija
            {
                DatumRezervacije = DateTime.Now.AddDays(2),
                KorisnikId = users.Single(u => u.Username == "frizer").KorisnikId,
                KlijentId = users.Single(u => u.Username == "klijent").KorisnikId,
                UslugaId = services.Single(s => s.Naziv == "Šišanje i brijanje").UslugaId,
                Termins = new List<Termin>
                {
                    new Termin
                    {
                        Vrijeme = DateTime.Now.AddDays(2).AddHours(10),
                        isBooked = true,
                        KorisnikID = users.Single(u => u.Username == "frizer").KorisnikId,
                        KlijentId = users.Single(u => u.Username == "klijent").KorisnikId
                    }
                }
            }
        };

        foreach (var a in appointments)
        {
            context.Rezervacija.Add(a);
        }
        context.SaveChanges();
    }

    private static string GenerateSalt()
    {
        var provider = new RNGCryptoServiceProvider();
        var byteArray = new byte[16];
        provider.GetBytes(byteArray);

        return Convert.ToBase64String(byteArray);
    }

    private static string GenerateHash(string salt, string password)
    {
        byte[] src = Convert.FromBase64String(salt);
        byte[] bytes = Encoding.Unicode.GetBytes(password);
        byte[] dst = new byte[src.Length + bytes.Length];

        Buffer.BlockCopy(src, 0, dst, 0, src.Length);
        Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

        var algorithm = HashAlgorithm.Create("SHA1");
        var inArray = algorithm?.ComputeHash(dst);

        return Convert.ToBase64String(inArray);
    }
}