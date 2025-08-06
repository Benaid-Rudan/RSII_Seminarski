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
  zauzetostPoSatima: (json['zauzetostPoSatima'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  ukupnaZauzetost: (json['ukupnaZauzetost'] as num?)?.toDouble(),
  preporuceniTermini:
      (json['preporuceniTermini'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$PredvidjanjeZauzetostiToJson(
  PredvidjanjeZauzetosti instance,
) => <String, dynamic>{
  'predvidjanjeId': instance.predvidjanjeId,
  'datum': instance.datum?.toIso8601String(),
  'korisnikId': instance.korisnikId,
  'zauzetostPoSatima': instance.zauzetostPoSatima,
  'ukupnaZauzetost': instance.ukupnaZauzetost,
  'preporuceniTermini': instance.preporuceniTermini,
};
