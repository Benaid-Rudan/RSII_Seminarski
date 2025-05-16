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

        var products = new Proizvod[]
        {
            new Proizvod
            {
                Naziv = "Šampon za muškarce",
                Opis = "Profesionalni šampon za mušku kosu",
                Cijena = 16.00m,
                Zalihe = 50,
                VrstaProizvodaId = 1,
                Slika = "https://www.biramzdravlje.hr/storage/upload/products/Pantogar-sampon-protiv-opadanja-kose-za-muskarce_133819.png"
            },
            new Proizvod
            {
                Naziv = "Krema za brijanje Classic",
                Opis = "Krema za glatko i ugodno brijanje",
                Cijena = 12.50m,
                Zalihe = 30,
                VrstaProizvodaId = 2,
                Slika = "https://www.just.hr/wp-content/uploads/2020/08/just-proizvodi-za-muskarce-gel-za-brijanje-819x1024.png"
            },
            new Proizvod
            {
                Naziv = "Gel za kosu Strong Hold",
                Opis = "Gel za fiksiranje frizure",
                Cijena = 9.00m,
                Zalihe = 40,
                VrstaProizvodaId = 3,
                Slika = "https://w7.pngwing.com/pngs/394/339/png-transparent-lotion-nivea-hair-styling-products-hairstyle-hair-gel-hair-gel.png"
            },
            new Proizvod
                {
                    Naziv = "Šampon protiv peruti",
                    Opis = "Efikasan šampon za uklanjanje peruti",
                    Cijena = 14.90m,
                    Zalihe = 35,
                    VrstaProizvodaId = 1,
                    Slika = "https://media.dm-static.com/images/f_auto,q_auto,c_fit,h_1200,w_1200/v1744973382/products/pim/3337871331290-010191/vichy-dercos-anti-dandruff-sampon-protiv-peruti"
                },
            new Proizvod
            {
                Naziv = "Prirodno ulje za bradu",
                Opis = "Ulje na bazi argana i jojobe za meku i zdravu bradu",
                Cijena = 18.00m,
                Zalihe = 25,
                VrstaProizvodaId = 4,
                Slika = "https://www.tinktura.com/slike/male/beard-stache-oil-41136-02140007.png"
            },
            new Proizvod
            {
                Naziv = "Gel za kosu Wet Look",
                Opis = "Daje mokar izgled i čvrstu postojanost",
                Cijena = 11.00m,
                Zalihe = 45,
                VrstaProizvodaId = 3,
                Slika = "https://licilasicdn.s3.amazonaws.com/public/product_images/47995/gallery/original/24564962.jpg"
            },
            new Proizvod
            {
                Naziv = "Brijačka krema Mentol",
                Opis = "Osvježavajuća krema za brijanje s mentolom",
                Cijena = 10.50m,
                Zalihe = 20,
                VrstaProizvodaId = 2,
                Slika = "https://m.media-amazon.com/images/I/51JiNzI-SoL._SL1500_.jpg"
            },
            new Proizvod
            {
                Naziv = "Šampon za suvu kosu",
                Opis = "Hidratantni šampon za suvu i oštećenu kosu",
                Cijena = 15.00m,
                Zalihe = 28,
                VrstaProizvodaId = 1,
                Slika = "https://webshop.afroditacosmetics.com/bih/image/cache/1001-2000/1132/main/d7a3-Hair-Care-ESSENCE-Hranilni-sampon_320-ml-900x1040-0-2.jpg"
            },
            new Proizvod
            {
                Naziv = "Ulje za bradu Citrus Fresh",
                Opis = "Ulje sa citrusnim notama za negu i stilizovanje brade",
                Cijena = 19.90m,
                Zalihe = 32,
                VrstaProizvodaId = 4,
                Slika = "https://www.lijepa.hr/data/cache/thumb_min500_max1000-min500_max1000-12/products/451227/1687444971/angry-beards-beard-oil-bobby-citrus-ulje-za-bradu-za-muskarce-30-ml-487144.jpg"
            },
            new Proizvod
            {
                Naziv = "Strong Fix gel za kosu",
                Opis = "Dugotrajna formula za čvrsto učvršćivanje frizure",
                Cijena = 13.00m,
                Zalihe = 38,
                VrstaProizvodaId = 3,
                Slika = "https://frizerland.ba/wp-content/uploads/2022/08/hd-lifestyle-strong-gel-firm-hold_9426_0.jpg"
            },
            new Proizvod
            {
                Naziv = "Šampon 2u1 Sport",
                Opis = "Šampon i regenerator za muškarce aktivnog stila",
                Cijena = 13.90m,
                Zalihe = 40,
                VrstaProizvodaId = 1,
                Slika = "https://i.makeup.hr/k/kn/knwqnissahks.jpg"
            },
            new Proizvod
            {
                Naziv = "Ulje za bradu Classic",
                Opis = "Klasična formula za svakodnevnu negu brade",
                Cijena = 17.00m,
                Zalihe = 27,
                VrstaProizvodaId = 4,
                Slika = "https://cdn.alexandar-cosmetics.com/media/cache/t760/images/products/6737104e0bc2b_25633.jpg"
            },
            new Proizvod
            {
                Naziv = "Krema za brijanje Sensitive",
                Opis = "Formula prilagođena osjetljivoj koži",
                Cijena = 11.50m,
                Zalihe = 22,
                VrstaProizvodaId = 2,
                Slika = "https://img.nivea.com/-/media/miscellaneous/media-center-items/b/a/b/81da96e8ca4942d9857b42ae8b57580b-web_1010x1180_transparent_png.png"
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

        var news = new Novost[]
        {
            new Novost
            {
                Naslov = "Dobrodošli u eBarbershop",
                Sadrzaj = "Radujemo se vašim posjetama u našem novom salonu!",
                DatumObjave = DateTime.Now.AddDays(-10),
                Slika = "https://meroscut.com/cdn/shop/files/cfb85b4bf155ff5423d0d78816c00ec5.jpg?v=1712334723&width=1445"
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
            },
            new Narudzba
            {
                Datum = DateTime.Now.AddDays(-5),
                UkupnaCijena = 45.50m,
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                NarudzbaProizvodis = new List<NarudzbaProizvodi>
                {
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Prirodno ulje za bradu").ProizvodId,
                        Kolicina = 1
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Brijačka krema Mentol").ProizvodId,
                        Kolicina = 2
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Šampon protiv peruti").ProizvodId,
                        Kolicina = 1
                    }
                }
            },
            new Narudzba
            {
                Datum = DateTime.Now.AddDays(-4),
                UkupnaCijena = 19.90m,
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                NarudzbaProizvodis = new List<NarudzbaProizvodi>
                {
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Ulje za bradu Citrus Fresh").ProizvodId,
                        Kolicina = 1
                    }
                }
            },
            new Narudzba
            {
                Datum = DateTime.Now.AddDays(-3),
                UkupnaCijena = 37.00m,
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                NarudzbaProizvodis = new List<NarudzbaProizvodi>
                {
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Šampon za suvu kosu").ProizvodId,
                        Kolicina = 2
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Gel za kosu Wet Look").ProizvodId,
                        Kolicina = 1
                    }
                }
            },
            new Narudzba
            {
                Datum = DateTime.Now.AddDays(-2),
                UkupnaCijena = 28.50m,
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                NarudzbaProizvodis = new List<NarudzbaProizvodi>
                {
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Krema za brijanje Classic").ProizvodId,
                        Kolicina = 1
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Krema za brijanje Sensitive").ProizvodId,
                        Kolicina = 1
                    }
                }
            },
            new Narudzba
            {
                Datum = DateTime.Now.AddDays(-1),
                UkupnaCijena = 62.80m,
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
                        ProizvodId = products.Single(p => p.Naziv == "Ulje za bradu Classic").ProizvodId,
                        Kolicina = 1
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Strong Fix gel za kosu").ProizvodId,
                        Kolicina = 2
                    }
                }
            },
            new Narudzba
            {
                Datum = DateTime.Now,
                UkupnaCijena = 13.90m,
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                NarudzbaProizvodis = new List<NarudzbaProizvodi>
                {
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Šampon 2u1 Sport").ProizvodId,
                        Kolicina = 1
                    }
                }
            },
            new Narudzba
            {
                Datum = DateTime.Now.AddDays(-6),
                UkupnaCijena = 24.00m,
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                NarudzbaProizvodis = new List<NarudzbaProizvodi>
                {
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Gel za kosu Strong Hold").ProizvodId,
                        Kolicina = 1
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Gel za kosu Wet Look").ProizvodId,
                        Kolicina = 1
                    }
                }
            },
            new Narudzba
            {
                Datum = DateTime.Now.AddDays(-7),
                UkupnaCijena = 29.00m,
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                NarudzbaProizvodis = new List<NarudzbaProizvodi>
                {
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Šampon protiv peruti").ProizvodId,
                        Kolicina = 1
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Prirodno ulje za bradu").ProizvodId,
                        Kolicina = 1
                    }
                }
            },
            new Narudzba
            {
                Datum = DateTime.Now.AddDays(-8),
                UkupnaCijena = 51.50m,
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                NarudzbaProizvodis = new List<NarudzbaProizvodi>
                {
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Šampon za suvu kosu").ProizvodId,
                        Kolicina = 2
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Brijačka krema Mentol").ProizvodId,
                        Kolicina = 1
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Ulje za bradu Citrus Fresh").ProizvodId,
                        Kolicina = 1
                    }
                }
            },
            new Narudzba
            {
                Datum = DateTime.Now.AddDays(-9),
                UkupnaCijena = 35.00m,
                KorisnikId = users.Single(u => u.Username == "klijent").KorisnikId,
                NarudzbaProizvodis = new List<NarudzbaProizvodi>
                {
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Krema za brijanje Classic").ProizvodId,
                        Kolicina = 1
                    },
                    new NarudzbaProizvodi
                    {
                        ProizvodId = products.Single(p => p.Naziv == "Strong Fix gel za kosu").ProizvodId,
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
                NacinUplate = "Paypal",
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