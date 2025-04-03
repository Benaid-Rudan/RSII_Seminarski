// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Novost _$NovostFromJson(Map<String, dynamic> json) => Novost(
  novostId: (json['novostId'] as num?)?.toInt(),
  naslov: json['naslov'] as String?,
  sadrzaj: json['sadrzaj'] as String?,
  datumObjave:
      json['datumObjave'] == null
          ? null
          : DateTime.parse(json['datumObjave'] as String),
  slika: json['slika'] as String?,
);

Map<String, dynamic> _$NovostToJson(Novost instance) => <String, dynamic>{
  'novostId': instance.novostId,
  'naslov': instance.naslov,
  'sadrzaj': instance.sadrzaj,
  'datumObjave': instance.datumObjave?.toIso8601String(),
  'slika': instance.slika,
};
