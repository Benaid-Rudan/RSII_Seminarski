import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/termin.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';
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
  List<Termin>? termini;

  Rezervacija(this.rezervacijaId, this.datumRezervacije, this.korisnikId,
      this.uslugaId, this.usluga, this.korisnik);

  factory Rezervacija.fromJson(Map<String, dynamic> json) =>
      _$RezervacijaFromJson(json);
  Map<String, dynamic> toJson() => _$RezervacijaToJson(this);
}
