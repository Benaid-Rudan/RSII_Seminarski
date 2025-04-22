import 'dart:convert';
import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider() : super("Korisnici"); // Postavi endpoint za korisnike
  static String? _baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "https://localhost:7286/");
  }
  @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }
  Future<Korisnik> authenticate(String username, String password) async {
    return await login(username, password);
  }
   
} 
