import 'package:json_annotation/json_annotation.dart';
import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';

part 'preporuka_termina.g.dart';

@JsonSerializable()
class PreporukaTermina {
  int? preporukaId;
  int? klijentId;
  Korisnik? klijent;
  DateTime? preporuceniTermin;
  int? korisnikId;
  Korisnik? korisnik;
  int? uslugaId;
  Usluga? usluga;
  double? skorPovjerenja;
  String? razlogPreporuke;
  bool? isAccepted;

  PreporukaTermina({
    this.preporukaId,
    this.klijentId,
    this.klijent,
    this.preporuceniTermin,
    this.korisnikId,
    this.korisnik,
    this.uslugaId,
    this.usluga,
    this.skorPovjerenja,
    this.razlogPreporuke,
    this.isAccepted,
  });

  factory PreporukaTermina.fromJson(Map<String, dynamic> json) => 
      _$PreporukaTerminaFromJson(json);
  
  Map<String, dynamic> toJson() => _$PreporukaTerminaToJson(this);
}