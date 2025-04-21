import 'dart:convert';
import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider() : super("Korisnici"); // Postavi endpoint za korisnike

  @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }
  Future<Korisnik> authenticate(String username, String password) async {
    return await login(username, password);
  }
}
