import 'package:json_annotation/json_annotation.dart';

part 'vrsta_proizvoda.g.dart';

@JsonSerializable()
class VrstaProizvoda {
  int? vrstaProizvodaId;
  String? naziv;

  VrstaProizvoda(this.vrstaProizvodaId, this.naziv);

  factory VrstaProizvoda.fromJson(Map<String, dynamic> json) =>
      _$VrstaProizvodaFromJson(json);
  Map<String, dynamic> toJson() => _$VrstaProizvodaToJson(this);
}
