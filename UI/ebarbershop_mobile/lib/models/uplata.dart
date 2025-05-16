import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/termin.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';
import 'package:json_annotation/json_annotation.dart';

part 'uplata.g.dart';
@JsonSerializable()
class Uplata {
  int? uplataId;
  DateTime? datumUplate;
  double? iznos; 
  String? nacinUplate;
  int? narudzbaId;
  Uplata({
    this.uplataId,
    this.datumUplate,
    this.iznos,
    this.nacinUplate,
    this.narudzbaId,
  });

  factory Uplata.fromJson(Map<String, dynamic> json) => _$UplataFromJson(json);
  Map<String, dynamic> toJson() => _$UplataToJson(this);
}