import 'dart:convert';
import 'package:ebarbershop_admin/models/narudzba.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';

class NarudzbaProvider extends BaseProvider<Narudzba> {
  NarudzbaProvider() : super("Narudzba"); // Postavi endpoint za korisnike

  @override
  Narudzba fromJson(data) {
    return Narudzba.fromJson(data);
  }
}
