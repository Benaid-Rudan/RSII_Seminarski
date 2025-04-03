import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  int recenzijaId;
  String komentar;
  int ocjena;
  String datum;
  int korisnikId;
  Korisnik? korisnik;

  Review(
    this.recenzijaId,
    this.komentar,
    this.ocjena,
    this.datum,
    this.korisnikId,
    this.korisnik,
  );

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}



