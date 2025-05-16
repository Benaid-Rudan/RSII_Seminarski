import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/rezervacija.dart';
import 'package:json_annotation/json_annotation.dart';

part 'termin.g.dart';

@JsonSerializable()
class Termin {
  int? terminId;
  String? terminUposelnik;
  DateTime? vrijeme;
  int? rezervacijaId;
  Rezervacija? rezervacija;
  bool? isBooked;
  int? korisnikID;
  Korisnik? korisnik;
  int? klijentId; // logirani korisnik
  Korisnik? klijent;

  Termin({
    this.terminId,
    this.terminUposelnik,
    this.vrijeme,
    this.rezervacijaId,
    this.rezervacija,
    this.isBooked,
    this.korisnikID,
    this.korisnik,
    this.klijentId,
    this.klijent,
  });

  factory Termin.fromJson(Map<String, dynamic> json) => _$TerminFromJson(json);
  Map<String, dynamic> toJson() => _$TerminToJson(this);
}
