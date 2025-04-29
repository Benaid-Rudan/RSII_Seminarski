using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace eBarbershop.Services.Database;

public partial class EBarbershop1Context : DbContext
{

    public EBarbershop1Context(DbContextOptions<EBarbershop1Context> options)
        : base(options)
    {
    }

    public virtual DbSet<Drzava> Drzava { get; set; }

    public virtual DbSet<Grad> Grad { get; set; }

    public virtual DbSet<Korisnik> Korisnik { get; set; }

    public virtual DbSet<KorisnikUloga> KorisnikUloga { get; set; }

    public virtual DbSet<Narudzba> Narudzba { get; set; }

    public virtual DbSet<NarudzbaProizvodi> NarudzbaProizvodi { get; set; }

    public virtual DbSet<Novost> Novost { get; set; }

    public virtual DbSet<Proizvod> Proizvod { get; set; }

    public virtual DbSet<Recenzija> Recenzija { get; set; }

    public virtual DbSet<Rezervacija> Rezervacija { get; set; }


    public virtual DbSet<Termin> Termin { get; set; }

    public virtual DbSet<Uloga> Uloga { get; set; }

    public virtual DbSet<Uplatum> Uplata { get; set; }

    public virtual DbSet<Usluga> Usluga { get; set; }

    public virtual DbSet<VrstaProizvoda> VrstaProizvoda { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=db;Database=NovaBaza;User=SA;Password=Benaid123!;TrustServerCertificate=True;Encrypt=false;MultipleActiveResultSets=true");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Drzava>(entity =>
        {
            entity.HasKey(e => e.DrzavaId).HasName("PK__Drzava__89CED866591BA42A");

            entity.ToTable("Drzava");

            entity.Property(e => e.Naziv).HasMaxLength(100);
        });

        modelBuilder.Entity<Grad>(entity =>
        {
            entity.HasKey(e => e.GradId).HasName("PK__Grad__B0F3C9A40E7669BB");

            entity.ToTable("Grad");

            entity.Property(e => e.Naziv).HasMaxLength(100);

            entity.HasOne(d => d.Drzava).WithMany(p => p.Grads)
                .HasForeignKey(d => d.DrzavaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Grad__DrzavaId__267ABA7A");
        });

        modelBuilder.Entity<Korisnik>(entity =>
        {
            entity.HasKey(e => e.KorisnikId).HasName("PK__Korisnik__80B06D41AE76B96F");

            entity.ToTable("Korisnik");

            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.Ime).HasMaxLength(100);
            entity.Property(e => e.PasswordHash).HasMaxLength(100);
            entity.Property(e => e.PasswordSalt).HasMaxLength(100);
            entity.Property(e => e.Prezime).HasMaxLength(100);
            entity.Property(e => e.Username).HasMaxLength(100);

            entity.HasOne(d => d.Grad).WithMany(p => p.Korisniks)
                .HasForeignKey(d => d.GradId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Korisnik__GradId__2B3F6F97");
        });

        modelBuilder.Entity<KorisnikUloga>(entity =>
        {
            entity.HasKey(e => e.KorisnikUlogaId).HasName("PK__Korisnik__1608726E6214C21C");

            entity.ToTable("KorisnikUloga");

            entity.Property(e => e.DatumDodjele).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.KorisnikUlogas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__KorisnikU__Koris__2E1BDC42");

            entity.HasOne(d => d.Uloga).WithMany(p => p.KorisnikUlogas)
                .HasForeignKey(d => d.UlogaId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__KorisnikU__Uloga__2F10007B");
        });

        modelBuilder.Entity<Narudzba>(entity =>
        {
            entity.HasKey(e => e.NarudzbaId).HasName("PK__Narudzba__FBEC1377BD7AD867");

            entity.ToTable("Narudzba");

            entity.Property(e => e.Datum).HasColumnType("datetime");
            entity.Property(e => e.UkupnaCijena).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Narudzbas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Narudzba__Korisn__38996AB5");
        });

        modelBuilder.Entity<NarudzbaProizvodi>(entity =>
        {
            entity.HasKey(e => e.NarudzbaProizvodiId).HasName("PK__Narudzba__FCDB224678561EBB");

            entity.ToTable("NarudzbaProizvodi");


            entity.HasOne(d => d.Narudzba).WithMany(p => p.NarudzbaProizvodis)
                .HasForeignKey(d => d.NarudzbaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__NarudzbaP__Narud__3B75D760");

            entity.HasOne(d => d.Proizvod).WithMany(p => p.NarudzbaProizvodis)
                .HasForeignKey(d => d.ProizvodId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__NarudzbaP__Proiz__3C69FB99");
        });

        modelBuilder.Entity<Novost>(entity =>
        {
            entity.HasKey(e => e.NovostId).HasName("PK__Novost__967A35FC7B241E07");

            entity.ToTable("Novost");

            entity.Property(e => e.DatumObjave).HasColumnType("datetime");
            entity.Property(e => e.Naslov).HasMaxLength(100);
        });

        modelBuilder.Entity<Proizvod>(entity =>
        {
            entity.HasKey(e => e.ProizvodId).HasName("PK__Proizvod__21A8BFF826638918");

            entity.ToTable("Proizvod");

            entity.Property(e => e.Cijena).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Naziv).HasMaxLength(100);
            entity.Property(e => e.Opis).HasMaxLength(255);

            entity.HasOne(d => d.VrstaProizvoda).WithMany(p => p.Proizvods)
                .HasForeignKey(d => d.VrstaProizvodaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Proizvod__VrstaP__35BCFE0A");
        });

        modelBuilder.Entity<Recenzija>(entity =>
        {
            entity.HasKey(e => e.RecenzijaId).HasName("PK__Recenzij__D36C6070ABDA537D");

            entity.ToTable("Recenzija");

            entity.Property(e => e.Datum).HasColumnType("datetime");
            entity.Property(e => e.Komentar).HasMaxLength(255);

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Recenzijas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Recenzija__Koris__4316F928");

            
        });

        modelBuilder.Entity<Rezervacija>(entity =>
        {
            entity.HasKey(e => e.RezervacijaId).HasName("PK__Rezervac__CABA44DD9B589314");

            entity.ToTable("Rezervacija");

            entity.Property(e => e.DatumRezervacije).HasColumnType("datetime");

            // Veza sa frizerom (korisnik koji izvodi uslugu)
            entity.HasOne(d => d.Korisnik)
                .WithMany(p => p.RezervacijeKaoFrizer)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.Restrict) // Keep as Restrict or change to Cascade if you want cascading delete
                .HasConstraintName("FK__Rezervaci__Koris__3F466844");

            // Veza sa klijentom (korisnik koji rezerviše termin)
            entity.HasOne(d => d.Klijent)
                .WithMany(p => p.RezervacijeKaoKlijent)
                .HasForeignKey(d => d.KlijentId)
                .OnDelete(DeleteBehavior.Restrict) // Keep as Restrict or change to Cascade if you want cascading delete
                .HasConstraintName("FK__Rezervaci__Klijen__NOVI_CONSTRAINT");

            // Veza sa uslugom
            entity.HasOne(d => d.Usluga)
                .WithMany(p => p.Rezervacijas)
                .HasForeignKey(d => d.UslugaId)
                .OnDelete(DeleteBehavior.ClientSetNull) // As per your requirement
                .HasConstraintName("FK__Rezervaci__Uslug__403A8C7D");

             entity.HasMany(r => r.Termins)
            .WithOne(t => t.Rezervacija)
            .HasForeignKey(t => t.RezervacijaId)
            .OnDelete(DeleteBehavior.Cascade);

        });

        modelBuilder.Entity<Termin>(entity =>
        {
            entity.HasKey(e => e.TerminId);

            entity.Property(e => e.Vrijeme).HasColumnType("datetime");

            // Veza sa frizerom
            entity.HasOne(d => d.Korisnik)
                .WithMany()
                .HasForeignKey(d => d.KorisnikID)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_Termin_Korisnik_Frizer");

            // Veza sa klijentom
            entity.HasOne(d => d.Klijent)
                .WithMany()
                .HasForeignKey(d => d.KlijentId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_Termin_Korisnik_Klijent");

            // Veza sa rezervacijom (already defined in Rezervacija)
            entity.HasOne(d => d.Rezervacija)
                .WithMany(r => r.Termins)
                .HasForeignKey(d => d.RezervacijaId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_Termin_Rezervacija");
        });



        modelBuilder.Entity<Uloga>(entity =>
        {
            entity.HasKey(e => e.UlogaId).HasName("PK__Uloga__DCAB23CB9B2604BB");

            entity.ToTable("Uloga");

            entity.Property(e => e.Naziv).HasMaxLength(100);
        });

        modelBuilder.Entity<Uplatum>(entity =>
        {
            entity.HasKey(e => e.UplataId).HasName("PK__Uplata__C5B165E6CD6C7172");

            entity.Property(e => e.DatumUplate).HasColumnType("datetime");
            entity.Property(e => e.Iznos).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.NacinUplate).HasMaxLength(100);

            entity.HasOne(d => d.Narudzba).WithMany(p => p.Uplata)
                .HasForeignKey(d => d.NarudzbaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Uplata__Narudzba__5070F446");
        });

        modelBuilder.Entity<Usluga>(entity =>
        {
            entity.HasKey(e => e.UslugaId).HasName("PK__Usluga__0BE5E72F6E1F853F");

            entity.ToTable("Usluga");

            entity.Property(e => e.Cijena).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Naziv).HasMaxLength(100);
            entity.Property(e => e.Opis).HasMaxLength(255);
        });

        modelBuilder.Entity<VrstaProizvoda>(entity =>
        {
            entity.HasKey(e => e.VrstaProizvodaId).HasName("PK__VrstaPro__7DC005E063976FC1");

            entity.Property(e => e.Naziv).HasMaxLength(100);
            
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
