import 'package:ebarbershop_admin/models/narudzbaproizvodi.dart';
import 'package:json_annotation/json_annotation.dart';

part 'narudzba.g.dart';

@JsonSerializable()
class Narudzba {
  int? narudzbaId;
  DateTime? datum;
  int? korisnikId;
  double? ukupnaCijena;
  List<NarudzbaProizvodi>? narudzbaProizvodis;

  Narudzba(this.narudzbaId, this.datum, this.korisnikId, this.ukupnaCijena,
      this.narudzbaProizvodis);

  factory Narudzba.fromJson(Map<String, dynamic> json) =>
      _$NarudzbaFromJson(json);
  Map<String, dynamic> toJson() => _$NarudzbaToJson(this);
}
  
