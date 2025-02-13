import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usluga.g.dart';

@JsonSerializable()
class Usluga {
  int? uslugaId;
  String? naziv;
  String? opis;
  double? cijena;

  Usluga(this.uslugaId, this.naziv, this.opis, this.cijena);

  factory Usluga.fromJson(Map<String, dynamic> json) => _$UslugaFromJson(json);
  Map<String, dynamic> toJson() => _$UslugaToJson(this);
}
