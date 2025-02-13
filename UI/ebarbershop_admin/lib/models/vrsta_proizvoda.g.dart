// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vrsta_proizvoda.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VrstaProizvoda _$VrstaProizvodaFromJson(Map<String, dynamic> json) =>
    VrstaProizvoda(
      (json['vrstaProizvodaId'] as num?)?.toInt(),
      json['naziv'] as String?,
    );

Map<String, dynamic> _$VrstaProizvodaToJson(VrstaProizvoda instance) =>
    <String, dynamic>{
      'vrstaProizvodaId': instance.vrstaProizvodaId,
      'naziv': instance.naziv,
    };
