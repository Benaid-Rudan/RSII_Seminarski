import 'dart:convert';
import 'package:ebarbershop_admin/models/novost.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';

class NovostProvider extends BaseProvider<Novost> {
  NovostProvider() : super("Novost"); // Postavi endpoint za korisnike

  @override
  Novost fromJson(data) {
    return Novost.fromJson(data);
  }
}
