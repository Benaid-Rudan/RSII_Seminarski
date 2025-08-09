import 'package:ebarbershop_mobile/models/zauzetost_po_satu.dart';
import 'package:json_annotation/json_annotation.dart';

part 'predvidjanje_zauzetosti.g.dart';

@JsonSerializable()
class PredvidjanjeZauzetosti {
  int? predvidjanjeId;
  int? korisnikId;
  DateTime? datum;
  List<ZauzetostPoSatu>? zauzetostPoSatima;

  double? ukupnaZauzetost;
  List<String>? preporuceniTermini;
  bool? isPredvidjeno;
  PredvidjanjeZauzetosti({
    this.predvidjanjeId,
    this.datum,
    this.korisnikId,
    this.zauzetostPoSatima,
    this.ukupnaZauzetost,
    this.preporuceniTermini,
    this.isPredvidjeno,
  });

  factory PredvidjanjeZauzetosti.fromJson(Map<String, dynamic> json) => 
      _$PredvidjanjeZauzetostiFromJson(json);
  
  Map<String, dynamic> toJson() => _$PredvidjanjeZauzetostiToJson(this);
}