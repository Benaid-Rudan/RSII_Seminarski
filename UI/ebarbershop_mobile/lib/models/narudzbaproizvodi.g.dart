// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narudzbaproizvodi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NarudzbaProizvodi _$NarudzbaProizvodiFromJson(Map<String, dynamic> json) =>
    NarudzbaProizvodi(
      (json['narudzbaProizvodiId'] as num?)?.toInt(),
      (json['narudzbaId'] as num?)?.toInt(),
      (json['proizvodId'] as num?)?.toInt(),
      json['proizvod'] == null
          ? null
          : Product.fromJson(json['proizvod'] as Map<String, dynamic>),
      (json['kolicina'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NarudzbaProizvodiToJson(NarudzbaProizvodi instance) =>
    <String, dynamic>{
      'narudzbaProizvodiId': instance.narudzbaProizvodiId,
      'narudzbaId': instance.narudzbaId,
      'proizvodId': instance.proizvodId,
      'proizvod': instance.proizvod,
      'kolicina': instance.kolicina,
    };
