// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uplata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Uplata _$UplataFromJson(Map<String, dynamic> json) => Uplata(
  uplataId: (json['uplataId'] as num?)?.toInt(),
  datumUplate:
      json['datumUplate'] == null
          ? null
          : DateTime.parse(json['datumUplate'] as String),
  iznos: (json['iznos'] as num?)?.toDouble(),
  nacinUplate: json['nacinUplate'] as String?,
  narudzbaId: (json['narudzbaId'] as num?)?.toInt(),
);

Map<String, dynamic> _$UplataToJson(Uplata instance) => <String, dynamic>{
  'uplataId': instance.uplataId,
  'datumUplate': instance.datumUplate?.toIso8601String(),
  'iznos': instance.iznos,
  'nacinUplate': instance.nacinUplate,
  'narudzbaId': instance.narudzbaId,
};
