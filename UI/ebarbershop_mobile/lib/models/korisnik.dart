// korisnik.dart
import 'package:ebarbershop_mobile/models/korisnik_uloga.dart';
import 'package:json_annotation/json_annotation.dart';

part 'korisnik.g.dart';

@JsonSerializable()
class Korisnik {
  int? korisnikId;
  String? ime;
  String? prezime;
  String? email;
  String? username;
  String? slika;
  int? gradId;
  String? uloge;
  List<KorisnikUloga>? korisnikUlogas;

  Korisnik({
    this.korisnikId,
    this.ime,
    this.prezime,
    this.email,
    this.username,
    this.slika,
    this.gradId,
    this.uloge,
    this.korisnikUlogas,
  });

  factory Korisnik.fromJson(Map<String, dynamic> json) => _$KorisnikFromJson(json);
  Map<String, dynamic> toJson() => _$KorisnikToJson(this);

  String get fullName => '$ime $prezime';
  bool get isEmployee => korisnikUlogas?.any((uloga) => uloga.uloga?.naziv == 'Uposlenik') ?? false;
}

