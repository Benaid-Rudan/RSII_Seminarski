// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lista_cekanja.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListaCekanja _$ListaCekanjaFromJson(Map<String, dynamic> json) => ListaCekanja(
  listaCekanjaId: (json['listaCekanjaId'] as num?)?.toInt(),
  klijentId: (json['klijentId'] as num?)?.toInt(),
  frizerId: (json['frizerId'] as num?)?.toInt(),
  uslugaId: (json['uslugaId'] as num?)?.toInt(),
  datumPrijave:
      json['datumPrijave'] == null
          ? null
          : DateTime.parse(json['datumPrijave'] as String),
  zeljeniDatum:
      json['zeljeniDatum'] == null
          ? null
          : DateTime.parse(json['zeljeniDatum'] as String),
  zeljenoVrijeme: json['zeljenoVrijeme'] as String?,
  datumIsteka:
      json['datumIsteka'] == null
          ? null
          : DateTime.parse(json['datumIsteka'] as String),
  napomena: json['napomena'] as String?,
  status: $enumDecodeNullable(_$StatusCekanjaEnumMap, json['status']),
  prioritet: (json['prioritet'] as num?)?.toInt(),
  mLSkor: (json['mLSkor'] as num?)?.toDouble(),
  notifikacijaPoslana: json['notifikacijaPoslana'] as bool?,
  datumNotifikacije:
      json['datumNotifikacije'] == null
          ? null
          : DateTime.parse(json['datumNotifikacije'] as String),
  klijent:
      json['klijent'] == null
          ? null
          : Korisnik.fromJson(json['klijent'] as Map<String, dynamic>),
  frizer:
      json['frizer'] == null
          ? null
          : Korisnik.fromJson(json['frizer'] as Map<String, dynamic>),
  usluga:
      json['usluga'] == null
          ? null
          : Usluga.fromJson(json['usluga'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ListaCekanjaToJson(ListaCekanja instance) =>
    <String, dynamic>{
      'listaCekanjaId': instance.listaCekanjaId,
      'klijentId': instance.klijentId,
      'frizerId': instance.frizerId,
      'uslugaId': instance.uslugaId,
      'datumPrijave': instance.datumPrijave?.toIso8601String(),
      'zeljeniDatum': instance.zeljeniDatum?.toIso8601String(),
      'zeljenoVrijeme': instance.zeljenoVrijeme,
      'datumIsteka': instance.datumIsteka?.toIso8601String(),
      'napomena': instance.napomena,
      'status': _$StatusCekanjaEnumMap[instance.status],
      'prioritet': instance.prioritet,
      'mLSkor': instance.mLSkor,
      'notifikacijaPoslana': instance.notifikacijaPoslana,
      'datumNotifikacije': instance.datumNotifikacije?.toIso8601String(),
      'klijent': instance.klijent,
      'frizer': instance.frizer,
      'usluga': instance.usluga,
    };

const _$StatusCekanjaEnumMap = {
  StatusCekanja.Aktivna: 'Aktivna',
  StatusCekanja.Notificirana: 'Notificirana',
  StatusCekanja.Prihvacena: 'Prihvacena',
  StatusCekanja.Istekla: 'Istekla',
  StatusCekanja.Otkazana: 'Otkazana',
};

ListaCekanjaInsertRequest _$ListaCekanjaInsertRequestFromJson(
  Map<String, dynamic> json,
) => ListaCekanjaInsertRequest(
  frizerId: (json['frizerId'] as num).toInt(),
  klijentId: (json['klijentId'] as num).toInt(),
  uslugaId: (json['uslugaId'] as num).toInt(),
  zeljeniDatum: DateTime.parse(json['zeljeniDatum'] as String),
  zeljenoVrijeme: json['zeljenoVrijeme'] as String,
  napomena: json['napomena'] as String?,
  daniDoIsteka: (json['daniDoIsteka'] as num?)?.toInt() ?? 7,
);

Map<String, dynamic> _$ListaCekanjaInsertRequestToJson(
  ListaCekanjaInsertRequest instance,
) => <String, dynamic>{
  'frizerId': instance.frizerId,
  'klijentId': instance.klijentId,
  'uslugaId': instance.uslugaId,
  'zeljeniDatum': instance.zeljeniDatum.toIso8601String(),
  'zeljenoVrijeme': instance.zeljenoVrijeme,
  'napomena': instance.napomena,
  'daniDoIsteka': instance.daniDoIsteka,
};
