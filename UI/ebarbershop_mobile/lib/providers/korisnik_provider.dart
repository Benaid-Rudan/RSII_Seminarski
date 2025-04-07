import 'dart:convert';
import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/search_result.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider() : super("Korisnici");

  @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }

   Future<SearchResult<Korisnik>> getEmployees() async {
  var filter = {
    'IsUlogeIncluded': true,
  };
  
  var result = await get(filter: filter);
  
  // Filter only users with Uposlenik role
  result.result = result.result.where((k) => 
    k.korisnikUlogas?.any((uloga) => uloga.uloga?.naziv == 'Uposlenik') ?? false
  ).toList();
  
  return result;
}
}
