import 'dart:convert';
import 'package:ebarbershop_mobile/models/narudzba.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';

class NarudzbaProvider extends BaseProvider<Narudzba> {
  NarudzbaProvider() : super("Narudzba"); 

  @override
  Narudzba fromJson(data) {
    return Narudzba.fromJson(data);
  }
}
