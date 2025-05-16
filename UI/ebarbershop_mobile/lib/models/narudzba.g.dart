// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narudzba.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Narudzba _$NarudzbaFromJson(Map<String, dynamic> json) => Narudzba(
  (json['narudzbaId'] as num?)?.toInt(),
  json['datum'] == null ? null : DateTime.parse(json['datum'] as String),
  (json['korisnikId'] as num?)?.toInt(),
  (json['ukupnaCijena'] as num?)?.toDouble(),
  (json['narudzbaProizvodis'] as List<dynamic>?)
      ?.map((e) => NarudzbaProizvodi.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NarudzbaToJson(Narudzba instance) => <String, dynamic>{
  'narudzbaId': instance.narudzbaId,
  'datum': instance.datum?.toIso8601String(),
  'korisnikId': instance.korisnikId,
  'ukupnaCijena': instance.ukupnaCijena,
  'narudzbaProizvodis': instance.narudzbaProizvodis,
};
