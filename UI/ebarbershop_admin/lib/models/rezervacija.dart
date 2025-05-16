import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/models/termin.dart';
import 'package:ebarbershop_admin/models/usluga.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rezervacija.g.dart';

@JsonSerializable()
class Rezervacija {
  int? rezervacijaId;
  DateTime? datumRezervacije;
  int? korisnikId;
  Korisnik? korisnik;
  int? uslugaId;
  Usluga? usluga;
  Termin? termin;
  List<Termin>? termini;
  int? klijentId; // logirani korisnik
  Korisnik? klijent;
  Rezervacija(this.rezervacijaId, this.datumRezervacije, this.korisnikId,
      this.uslugaId, this.usluga, this.korisnik, this.klijentId, this.klijent, this.termin, this.termini);

  factory Rezervacija.fromJson(Map<String, dynamic> json) =>
      _$RezervacijaFromJson(json);
  Map<String, dynamic> toJson() => _$RezervacijaToJson(this);
}
