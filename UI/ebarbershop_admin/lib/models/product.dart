import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  int? proizvodId;
  String? naziv;
  String? opis;
  double? cijena;
  int? zalihe;
  String? slika;
  int? vrstaProizvodaId;
  Product(this.proizvodId, this.naziv, this.opis, this.cijena, this.slika,
      this.vrstaProizvodaId, this.zalihe);

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}


//     "proizvodId": 2,
//     "naziv": "Masinica za kosu",
//     "opis": "Masinica za kosu",
//     "cijena": 10,
//     "zalihe": 10,
//     "slika": "string",
//     "vrstaProizvodaId": 1