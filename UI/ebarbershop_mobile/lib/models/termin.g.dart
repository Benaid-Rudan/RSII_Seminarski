// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'termin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Termin _$TerminFromJson(Map<String, dynamic> json) => Termin(
  terminId: (json['terminId'] as num?)?.toInt(),
  terminUposelnik: json['terminUposelnik'] as String?,
  vrijeme:
      json['vrijeme'] == null
          ? null
          : DateTime.parse(json['vrijeme'] as String),
  rezervacijaId: (json['rezervacijaId'] as num?)?.toInt(),
  rezervacija:
      json['rezervacija'] == null
          ? null
          : Rezervacija.fromJson(json['rezervacija'] as Map<String, dynamic>),
  isBooked: json['isBooked'] as bool?,
  korisnikID: (json['korisnikID'] as num?)?.toInt(),
  korisnik:
      json['korisnik'] == null
          ? null
          : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>),
  klijentId: (json['klijentId'] as num?)?.toInt(),
  klijent:
      json['klijent'] == null
          ? null
          : Korisnik.fromJson(json['klijent'] as Map<String, dynamic>),
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
  'klijentId': instance.klijentId,
  'klijent': instance.klijent,
};
