import 'dart:convert';
import 'package:ebarbershop_mobile/models/rezervacija.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RezervacijaProvider extends BaseProvider<Rezervacija> {
  RezervacijaProvider() : super("Rezervacija");

  @override
  Rezervacija fromJson(data) {
    return Rezervacija.fromJson(data);
  }
}
