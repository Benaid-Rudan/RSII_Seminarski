import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';

part 'lista_cekanja.g.dart';

enum StatusCekanja {
  @JsonValue('Aktivna')
  Aktivna,

  @JsonValue('Notificirana')
  Notificirana,

  @JsonValue('Prihvacena')
  Prihvacena,

  @JsonValue('Istekla')
  Istekla,

  @JsonValue('Otkazana')
  Otkazana,
}


@JsonSerializable()
class ListaCekanja {
  int? listaCekanjaId;
  int? klijentId;
  int? frizerId;
  int? uslugaId;
  DateTime? datumPrijave;
  DateTime? zeljeniDatum;
  String? zeljenoVrijeme;
  DateTime? datumIsteka;
  String? napomena;
  StatusCekanja? status;
  int? prioritet;
  double? mLSkor;
  bool? notifikacijaPoslana;
  DateTime? datumNotifikacije;
  Korisnik? klijent;
  Korisnik? frizer;
  Usluga? usluga;

  ListaCekanja({
    this.listaCekanjaId,
    this.klijentId,
    this.frizerId,
    this.uslugaId,
    this.datumPrijave,
    this.zeljeniDatum,
    this.zeljenoVrijeme,
    this.datumIsteka,
    this.napomena,
    this.status,
    this.prioritet,
    this.mLSkor,
    this.notifikacijaPoslana,
    this.datumNotifikacije,
    this.klijent,
    this.frizer,
    this.usluga,
  });

  factory ListaCekanja.fromJson(Map<String, dynamic> json) => _$ListaCekanjaFromJson(json);
  Map<String, dynamic> toJson() => _$ListaCekanjaToJson(this);
}
class TimeOfDayConverter implements JsonConverter<TimeOfDay?, String?> {
  const TimeOfDayConverter();

  @override
  TimeOfDay? fromJson(String? json) {
    if (json == null) return null;
    final parts = json.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  String? toJson(TimeOfDay? object) {
    if (object == null) return null;
    return '${object.hour.toString().padLeft(2, '0')}:${object.minute.toString().padLeft(2, '0')}';
  }
}
@JsonSerializable()
class ListaCekanjaInsertRequest {
  final int frizerId;
  final int klijentId;
  final int uslugaId;
  final DateTime zeljeniDatum;
  
  @JsonKey(name: 'zeljenoVrijeme')
  final String zeljenoVrijeme; // This should be in "HH:mm:ss" format
  
  final String? napomena;
  final int daniDoIsteka;

  ListaCekanjaInsertRequest({
    required this.frizerId,
    required this.klijentId,
    required this.uslugaId,
    required this.zeljeniDatum,
    required this.zeljenoVrijeme,
    this.napomena,
    this.daniDoIsteka = 7,
  });

  factory ListaCekanjaInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$ListaCekanjaInsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ListaCekanjaInsertRequestToJson(this);

  // Helper method to create from TimeOfDay
  factory ListaCekanjaInsertRequest.fromTimeOfDay({
    required int frizerId,
    required int klijentId,
    required int uslugaId,
    required DateTime zeljeniDatum,
    required TimeOfDay time,
    String? napomena,
    int daniDoIsteka = 7,
  }) {
    return ListaCekanjaInsertRequest(
      frizerId: frizerId,
      klijentId: klijentId,
      uslugaId: uslugaId,
      zeljeniDatum: zeljeniDatum,
      zeljenoVrijeme: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      napomena: napomena,
      daniDoIsteka: daniDoIsteka,
    );
  }
}