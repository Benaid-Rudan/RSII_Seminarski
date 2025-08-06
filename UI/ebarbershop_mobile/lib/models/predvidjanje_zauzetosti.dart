import 'package:json_annotation/json_annotation.dart';

part 'predvidjanje_zauzetosti.g.dart';

@JsonSerializable()
class PredvidjanjeZauzetosti {
  int? predvidjanjeId;
  DateTime? datum;
  int? korisnikId;
  Map<String, double>? zauzetostPoSatima;
  double? ukupnaZauzetost;
  List<String>? preporuceniTermini;

  PredvidjanjeZauzetosti({
    this.predvidjanjeId,
    this.datum,
    this.korisnikId,
    this.zauzetostPoSatima,
    this.ukupnaZauzetost,
    this.preporuceniTermini,
  });

  factory PredvidjanjeZauzetosti.fromJson(Map<String, dynamic> json) => 
      _$PredvidjanjeZauzetostiFromJson(json);
  
  Map<String, dynamic> toJson() => _$PredvidjanjeZauzetostiToJson(this);
}