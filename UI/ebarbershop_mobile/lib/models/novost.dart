// TODO Implement this library.
import 'package:json_annotation/json_annotation.dart';

part 'novost.g.dart';

@JsonSerializable()
class Novost {
  int? novostId;
  String? naslov;
  String? sadrzaj;
  DateTime? datumObjave;
  String? slika;

  Novost({
    this.novostId,
    this.naslov,
    this.sadrzaj,
    this.datumObjave,
    this.slika,
  });

  factory Novost.fromJson(Map<String, dynamic> json) => _$NovostFromJson(json);
  Map<String, dynamic> toJson() => _$NovostToJson(this);

  // Helper method to get proper image URL
  String? get fullImageUrl {
    if (slika == null || slika!.isEmpty) return null;
    
    // If it's already a full URL
    if (slika!.startsWith('http')) return slika;
    
    // If it's base64 encoded
    if (slika!.startsWith('data:image')) return slika;
    
    // Otherwise, combine with your base URL
    return 'https://your-api-base-url.com/$slika';
  }
}

// [
//   {
//     "novostId": 4,
//     "naslov": "string",
//     "sadrzaj": "string",
//     "datumObjave": "2024-12-24T09:53:37.76",
//     "slika": "string"
//   }
// ]
