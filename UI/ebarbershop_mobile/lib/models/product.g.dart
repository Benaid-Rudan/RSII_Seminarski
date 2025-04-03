// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  (json['proizvodId'] as num?)?.toInt(),
  json['naziv'] as String?,
  json['opis'] as String?,
  (json['cijena'] as num?)?.toDouble(),
  json['slika'] as String?,
  (json['vrstaProizvodaId'] as num?)?.toInt(),
  (json['zalihe'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'proizvodId': instance.proizvodId,
  'naziv': instance.naziv,
  'opis': instance.opis,
  'cijena': instance.cijena,
  'zalihe': instance.zalihe,
  'slika': instance.slika,
  'vrstaProizvodaId': instance.vrstaProizvodaId,
};
