// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnikuloga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KorisnikUloga _$KorisnikUlogaFromJson(Map<String, dynamic> json) =>
    KorisnikUloga(
      korisnikUlogaId: (json['korisnikUlogaId'] as num?)?.toInt(),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      ulogaId: (json['ulogaId'] as num?)?.toInt(),
      uloga: json['uloga'] == null
          ? null
          : Uloga.fromJson(json['uloga'] as Map<String, dynamic>),
      datumDodjele: json['datumDodjele'] == null
          ? null
          : DateTime.parse(json['datumDodjele'] as String),
    );

Map<String, dynamic> _$KorisnikUlogaToJson(KorisnikUloga instance) =>
    <String, dynamic>{
      'korisnikUlogaId': instance.korisnikUlogaId,
      'korisnikId': instance.korisnikId,
      'ulogaId': instance.ulogaId,
      'uloga': instance.uloga,
      'datumDodjele': instance.datumDodjele?.toIso8601String(),
    };
