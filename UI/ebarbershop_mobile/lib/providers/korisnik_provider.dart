import 'dart:convert';
import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider() : super("Korisnici");

  @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }

  getCurrentUser() {}
}
