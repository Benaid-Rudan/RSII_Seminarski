// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zauzetost_po_satu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZauzetostPoSatu _$ZauzetostPoSatuFromJson(Map<String, dynamic> json) =>
    ZauzetostPoSatu(
      predvidjanjeId: (json['predvidjanjeId'] as num?)?.toInt(),
      sat: json['sat'] as String?,
      vrijednost: (json['vrijednost'] as num?)?.toDouble(),
      id: (json['id'] as num?)?.toInt(),
      predvidjanje:
          json['predvidjanje'] == null
              ? null
              : PredvidjanjeZauzetosti.fromJson(
                json['predvidjanje'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$ZauzetostPoSatuToJson(ZauzetostPoSatu instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sat': instance.sat,
      'vrijednost': instance.vrijednost,
      'predvidjanjeId': instance.predvidjanjeId,
      'predvidjanje': instance.predvidjanje,
    };
