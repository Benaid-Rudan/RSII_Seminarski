// TODO Implement this library.
import 'package:json_annotation/json_annotation.dart';

part 'uloga.g.dart';

@JsonSerializable()
class Uloga {
  int? ulogaId;
  String? naziv;

  Uloga({this.ulogaId, this.naziv});

  
  factory Uloga.fromJson(Map<String, dynamic> json) => _$UlogaFromJson(json);
  Map<String, dynamic> toJson() => _$UlogaToJson(this);
}
