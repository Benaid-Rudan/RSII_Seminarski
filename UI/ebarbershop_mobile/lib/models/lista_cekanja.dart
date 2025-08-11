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
  int frizerId;
  int klijentId;

  int uslugaId;
  DateTime zeljeniDatum;

  @TimeOfDayConverter()
  TimeOfDay? zeljenoVrijeme;

  String? napomena;
  int daniDoIsteka;
 int? klijentPrioritet;
   String? klijentHistorija;
  ListaCekanjaInsertRequest({
    required this.frizerId,
    required this.klijentId,
    required this.uslugaId,
    required this.zeljeniDatum,
    this.zeljenoVrijeme,
    this.napomena,
    this.daniDoIsteka = 7,
    this.klijentPrioritet,
    this.klijentHistorija,
  });

  factory ListaCekanjaInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$ListaCekanjaInsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ListaCekanjaInsertRequestToJson(this);
}
