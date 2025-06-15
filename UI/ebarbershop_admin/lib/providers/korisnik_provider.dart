import 'dart:convert';
import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';
import 'package:ebarbershop_admin/utils/util.dart';

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider() : super("Korisnici");

  @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }

  Future<Korisnik> authenticate(String username, String password) async {
    try {
      Authorization.username = username;
      Authorization.password = password;
      
      return await login(username, password);
    } catch (e) {
      print("Authentication error: $e");
      rethrow;
    }
  }
}