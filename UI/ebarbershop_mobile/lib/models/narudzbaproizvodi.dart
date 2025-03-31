import 'package:ebarbershop_mobile/models/product.dart';
import 'package:json_annotation/json_annotation.dart';

part 'narudzbaproizvodi.g.dart';

@JsonSerializable()
class NarudzbaProizvodi {
  int? narudzbaProizvodiId;
  int? narudzbaId;
  int? proizvodId;
  Product? proizvod;
  int? kolicina;
  NarudzbaProizvodi(this.narudzbaProizvodiId, this.narudzbaId, this.proizvodId,
      this.proizvod, this.kolicina);

  factory NarudzbaProizvodi.fromJson(Map<String, dynamic> json) =>
      _$NarudzbaProizvodiFromJson(json);

  Map<String, dynamic> toJson() => _$NarudzbaProizvodiToJson(this);
}
