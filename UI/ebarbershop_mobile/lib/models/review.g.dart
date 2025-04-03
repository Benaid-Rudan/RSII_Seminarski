// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  (json['recenzijaId'] as num).toInt(),
  json['komentar'] as String,
  (json['ocjena'] as num).toInt(),
  json['datum'] as String,
  (json['korisnikId'] as num).toInt(),
  json['korisnik'] == null
      ? null
      : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'recenzijaId': instance.recenzijaId,
  'komentar': instance.komentar,
  'ocjena': instance.ocjena,
  'datum': instance.datum,
  'korisnikId': instance.korisnikId,
  'korisnik': instance.korisnik,
};
