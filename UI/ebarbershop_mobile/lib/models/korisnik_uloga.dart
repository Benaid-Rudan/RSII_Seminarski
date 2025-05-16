import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/uloga.dart';
import 'package:json_annotation/json_annotation.dart';
part 'korisnik_uloga.g.dart';
@JsonSerializable()
class KorisnikUloga {
  int? korisnikUlogaId;
  int? korisnikId;
  int? ulogaId;
  Uloga? uloga;
  String? datumDodjele;
  Korisnik? korisnik;

  KorisnikUloga({
    this.korisnikUlogaId,
    this.korisnikId,
    this.ulogaId,
    this.uloga,
    this.datumDodjele,
    this.korisnik
  });

  factory KorisnikUloga.fromJson(Map<String, dynamic> json) => _$KorisnikUlogaFromJson(json);
  Map<String, dynamic> toJson() => _$KorisnikUlogaToJson(this);
}





//  Korisnik Korisnik 

