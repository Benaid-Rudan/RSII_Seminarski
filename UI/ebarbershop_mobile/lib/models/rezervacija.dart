import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/termin.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rezervacija.g.dart';

@JsonSerializable()
class Rezervacija {
  int? rezervacijaId;
  DateTime? datumRezervacije;
  int? korisnikId; // frizer
  Korisnik? korisnik;
  int? klijentId; // logirani korisnik
  Korisnik? klijent;
  int? uslugaId;
  Usluga? usluga;

  Rezervacija({
    this.rezervacijaId,
    this.datumRezervacije,
    this.korisnikId,
    this.korisnik,
    this.klijentId,
    this.klijent,
    this.uslugaId,
    this.usluga,
  });

  factory Rezervacija.fromJson(Map<String, dynamic> json) => _$RezervacijaFromJson(json);
  Map<String, dynamic> toJson() => _$RezervacijaToJson(this);
}