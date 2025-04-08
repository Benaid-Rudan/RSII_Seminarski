// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rezervacija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rezervacija _$RezervacijaFromJson(Map<String, dynamic> json) => Rezervacija(
  rezervacijaId: (json['rezervacijaId'] as num?)?.toInt(),
  datumRezervacije:
      json['datumRezervacije'] == null
          ? null
          : DateTime.parse(json['datumRezervacije'] as String),
  korisnikId: (json['korisnikId'] as num?)?.toInt(),
  korisnik:
      json['korisnik'] == null
          ? null
          : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>),
  klijentId: (json['klijentId'] as num?)?.toInt(),
  klijent:
      json['klijent'] == null
          ? null
          : Korisnik.fromJson(json['klijent'] as Map<String, dynamic>),
  uslugaId: (json['uslugaId'] as num?)?.toInt(),
  usluga:
      json['usluga'] == null
          ? null
          : Usluga.fromJson(json['usluga'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RezervacijaToJson(Rezervacija instance) =>
    <String, dynamic>{
      'rezervacijaId': instance.rezervacijaId,
      'datumRezervacije': instance.datumRezervacije?.toIso8601String(),
      'korisnikId': instance.korisnikId,
      'korisnik': instance.korisnik,
      'klijentId': instance.klijentId,
      'klijent': instance.klijent,
      'uslugaId': instance.uslugaId,
      'usluga': instance.usluga,
    };
