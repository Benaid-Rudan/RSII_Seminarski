
//  public int PredvidjanjeId { get; set; }  // FK
//  public PredvidjanjeZauzetosti Predvidjanje { get; set; }

import 'package:ebarbershop_mobile/models/predvidjanje_zauzetosti.dart';
import 'package:json_annotation/json_annotation.dart';

part 'zauzetost_po_satu.g.dart';

@JsonSerializable()
class ZauzetostPoSatu {
  int? id;
  String? sat;
  double? vrijednost;
  int? predvidjanjeId;
  PredvidjanjeZauzetosti? predvidjanje;

  ZauzetostPoSatu({
    this.predvidjanjeId,
    this.sat,
    this.vrijednost,
    this.id,
    this.predvidjanje,
  });

  factory ZauzetostPoSatu.fromJson(Map<String, dynamic> json) => 
      _$ZauzetostPoSatuFromJson(json);
  
  Map<String, dynamic> toJson() => _$ZauzetostPoSatuToJson(this);
}