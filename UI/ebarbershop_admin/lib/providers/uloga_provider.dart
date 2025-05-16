import 'dart:convert';
import 'package:ebarbershop_admin/models/grad.dart';
import 'package:ebarbershop_admin/models/uloga.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';

class UlogaProvider extends BaseProvider<Uloga> {
  UlogaProvider() : super("Uloga"); // Postavi endpoint za korisnike

  @override
  Uloga fromJson(data) {
    return Uloga.fromJson(data);
  }
}
