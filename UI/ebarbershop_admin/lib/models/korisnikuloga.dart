import 'package:ebarbershop_admin/models/uloga.dart';
import 'package:json_annotation/json_annotation.dart';

part 'korisnikuloga.g.dart';

@JsonSerializable()
class KorisnikUloga {
  int? korisnikUlogaId;
  int? korisnikId;
  int? ulogaId;
  Uloga? uloga;
  DateTime? datumDodjele;

  KorisnikUloga({
    this.korisnikUlogaId,
    this.korisnikId,
    this.ulogaId,
    this.uloga,
    this.datumDodjele,
  });
  factory KorisnikUloga.fromJson(Map<String, dynamic> json) =>
      _$KorisnikUlogaFromJson(json);
  Map<String, dynamic> toJson() => _$KorisnikUlogaToJson(this);
}
