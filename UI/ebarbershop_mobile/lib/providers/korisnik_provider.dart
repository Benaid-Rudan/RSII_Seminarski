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
  Future<Korisnik> authenticate(String username, String password) async {
  return await login(username, password);
}
   Future<SearchResult<Korisnik>> getEmployees() async {
  var filter = {
    'IsUlogeIncluded': true,
  };
  
  var result = await get(filter: filter);
  
  result.result = result.result.where((k) => 
    k.korisnikUlogas?.any((uloga) => uloga.uloga?.naziv == 'Frizer') ?? false
  ).toList();
  
  return result;
}

  

}
