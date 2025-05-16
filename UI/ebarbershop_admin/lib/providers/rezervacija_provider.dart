import 'dart:convert';
import 'package:ebarbershop_admin/models/rezervacija.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RezervacijaProvider extends BaseProvider<Rezervacija> {
  RezervacijaProvider() : super("Rezervacija");

  @override
  Rezervacija fromJson(data) {
    return Rezervacija.fromJson(data);
  }
}
