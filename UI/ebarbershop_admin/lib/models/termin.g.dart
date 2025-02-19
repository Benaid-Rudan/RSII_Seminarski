// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'termin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Termin _$TerminFromJson(Map<String, dynamic> json) => Termin(
      (json['terminId'] as num?)?.toInt(),
      json['terminUposelnik'] as String?,
      json['vrijeme'] == null
          ? null
          : DateTime.parse(json['vrijeme'] as String),
      (json['rezervacijaId'] as num?)?.toInt(),
      json['rezervacija'] == null
          ? null
          : Rezervacija.fromJson(json['rezervacija'] as Map<String, dynamic>),
      json['isBooked'] as bool?,
      (json['korisnikID'] as num?)?.toInt(),
      json['korisnik'] == null
          ? null
          : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TerminToJson(Termin instance) => <String, dynamic>{
      'terminId': instance.terminId,
      'terminUposelnik': instance.terminUposelnik,
      'vrijeme': instance.vrijeme?.toIso8601String(),
      'rezervacijaId': instance.rezervacijaId,
      'rezervacija': instance.rezervacija,
      'isBooked': instance.isBooked,
      'korisnikID': instance.korisnikID,
      'korisnik': instance.korisnik,
    };
