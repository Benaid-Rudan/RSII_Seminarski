import 'package:ebarbershop_mobile/models/narudzbaproizvodi.dart';
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
  // factory Narudzba.fromJson(Map<String, dynamic> json) => Narudzba(
  //       (json['narudzbaId'] as num?)?.toInt(),
  //       json['datum'] == null ? null : DateTime.parse(json['datum'] as String),
  //       (json['korisnikId'] as num?)?.toInt(),
  //       (json['ukupnaCijena'] as num?)?.toDouble(),
  //       json['narudzbaProizvodis'] == null
  //           ? []
  //           : (json['narudzbaProizvodis'] as List)
  //               .map((e) =>
  //                   NarudzbaProizvodi.fromJson(e as Map<String, dynamic>))
  //               .toList(),
  //     );
//  "narudzbaId": 1,
//     "datum": "2025-01-11T11:27:33.263",
//     "ukupnaCijena": 10,
//     "korisnikId": 6,
//     "narudzbaProizvodis": []
