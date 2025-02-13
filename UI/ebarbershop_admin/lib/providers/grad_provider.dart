import 'dart:convert';
import 'package:ebarbershop_admin/models/grad.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';

class GradProvider extends BaseProvider<Grad> {
  GradProvider() : super("Grad"); // Postavi endpoint za korisnike

  @override
  Grad fromJson(data) {
    return Grad.fromJson(data);
  }
}
