// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Korisnik _$KorisnikFromJson(Map<String, dynamic> json) => Korisnik(
  korisnikId: (json['korisnikId'] as num?)?.toInt(),
  ime: json['ime'] as String?,
  prezime: json['prezime'] as String?,
  email: json['email'] as String?,
  username: json['username'] as String?,
  slika: json['slika'] as String?,
  gradId: (json['gradId'] as num?)?.toInt(),
  uloge: json['uloge'] as String?,
);

Map<String, dynamic> _$KorisnikToJson(Korisnik instance) => <String, dynamic>{
  'korisnikId': instance.korisnikId,
  'ime': instance.ime,
  'prezime': instance.prezime,
  'email': instance.email,
  'username': instance.username,
  'slika': instance.slika,
  'gradId': instance.gradId,
  'uloge': instance.uloge,
};
