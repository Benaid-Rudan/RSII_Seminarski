// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preporuka_termina.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreporukaTermina _$PreporukaTerminaFromJson(Map<String, dynamic> json) =>
    PreporukaTermina(
      preporukaId: (json['preporukaId'] as num?)?.toInt(),
      klijentId: (json['klijentId'] as num?)?.toInt(),
      klijent:
          json['klijent'] == null
              ? null
              : Korisnik.fromJson(json['klijent'] as Map<String, dynamic>),
      preporuceniTermin:
          json['preporuceniTermin'] == null
              ? null
              : DateTime.parse(json['preporuceniTermin'] as String),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      korisnik:
          json['korisnik'] == null
              ? null
              : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>),
      uslugaId: (json['uslugaId'] as num?)?.toInt(),
      usluga:
          json['usluga'] == null
              ? null
              : Usluga.fromJson(json['usluga'] as Map<String, dynamic>),
      skorPovjerenja: (json['skorPovjerenja'] as num?)?.toDouble(),
      razlogPreporuke: json['razlogPreporuke'] as String?,
      isAccepted: json['isAccepted'] as bool?,
    );

Map<String, dynamic> _$PreporukaTerminaToJson(PreporukaTermina instance) =>
    <String, dynamic>{
      'preporukaId': instance.preporukaId,
      'klijentId': instance.klijentId,
      'klijent': instance.klijent,
      'preporuceniTermin': instance.preporuceniTermin?.toIso8601String(),
      'korisnikId': instance.korisnikId,
      'korisnik': instance.korisnik,
      'uslugaId': instance.uslugaId,
      'usluga': instance.usluga,
      'skorPovjerenja': instance.skorPovjerenja,
      'razlogPreporuke': instance.razlogPreporuke,
      'isAccepted': instance.isAccepted,
    };
