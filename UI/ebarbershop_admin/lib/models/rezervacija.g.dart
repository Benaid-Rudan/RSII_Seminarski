// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rezervacija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rezervacija _$RezervacijaFromJson(Map<String, dynamic> json) => Rezervacija(
      (json['rezervacijaId'] as num?)?.toInt(),
      json['datumRezervacije'] == null
          ? null
          : DateTime.parse(json['datumRezervacije'] as String),
      (json['korisnikId'] as num?)?.toInt(),
      (json['uslugaId'] as num?)?.toInt(),
      json['usluga'] == null
          ? null
          : Usluga.fromJson(json['usluga'] as Map<String, dynamic>),
      json['korisnik'] == null
          ? null
          : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>),
      (json['klijentId'] as num?)?.toInt(),
      json['klijent'] == null
          ? null
          : Korisnik.fromJson(json['klijent'] as Map<String, dynamic>),
      json['termin'] == null
          ? null
          : Termin.fromJson(json['termin'] as Map<String, dynamic>),
      (json['termini'] as List<dynamic>?)
          ?.map((e) => Termin.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RezervacijaToJson(Rezervacija instance) =>
    <String, dynamic>{
      'rezervacijaId': instance.rezervacijaId,
      'datumRezervacije': instance.datumRezervacije?.toIso8601String(),
      'korisnikId': instance.korisnikId,
      'korisnik': instance.korisnik,
      'uslugaId': instance.uslugaId,
      'usluga': instance.usluga,
      'termin': instance.termin,
      'termini': instance.termini,
      'klijentId': instance.klijentId,
      'klijent': instance.klijent,
    };
