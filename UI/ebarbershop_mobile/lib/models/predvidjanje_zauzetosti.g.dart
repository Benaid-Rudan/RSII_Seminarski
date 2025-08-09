// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'predvidjanje_zauzetosti.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredvidjanjeZauzetosti _$PredvidjanjeZauzetostiFromJson(
  Map<String, dynamic> json,
) => PredvidjanjeZauzetosti(
  predvidjanjeId: (json['predvidjanjeId'] as num?)?.toInt(),
  datum: json['datum'] == null ? null : DateTime.parse(json['datum'] as String),
  korisnikId: (json['korisnikId'] as num?)?.toInt(),
  zauzetostPoSatima:
      (json['zauzetostPoSatima'] as List<dynamic>?)
          ?.map((e) => ZauzetostPoSatu.fromJson(e as Map<String, dynamic>))
          .toList(),
  ukupnaZauzetost: (json['ukupnaZauzetost'] as num?)?.toDouble(),
  preporuceniTermini:
      (json['preporuceniTermini'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  isPredvidjeno: json['isPredvidjeno'] as bool?,
);

Map<String, dynamic> _$PredvidjanjeZauzetostiToJson(
  PredvidjanjeZauzetosti instance,
) => <String, dynamic>{
  'predvidjanjeId': instance.predvidjanjeId,
  'korisnikId': instance.korisnikId,
  'datum': instance.datum?.toIso8601String(),
  'zauzetostPoSatima': instance.zauzetostPoSatima,
  'ukupnaZauzetost': instance.ukupnaZauzetost,
  'preporuceniTermini': instance.preporuceniTermini,
  'isPredvidjeno': instance.isPredvidjeno,
};
