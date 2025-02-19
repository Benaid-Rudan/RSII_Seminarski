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

  Korisnik({
    this.korisnikId,
    this.ime,
    this.prezime,
    this.email,
    this.username,
    this.slika,
    this.gradId,
    this.uloge,
  });
  factory Korisnik.fromJson(Map<String, dynamic> json) =>
      _$KorisnikFromJson(json);
  Map<String, dynamic> toJson() => _$KorisnikToJson(this);
}
