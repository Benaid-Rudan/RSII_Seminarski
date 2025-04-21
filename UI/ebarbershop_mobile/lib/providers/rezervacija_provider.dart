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
  Future<Rezervacija> createReservation({
  required DateTime datumRezervacije,
  required int korisnikId, // frizer
  required int klijentId, // logirani korisnik
  required int uslugaId,
}) async {
  var request = {
    'datumRezervacije': datumRezervacije.toIso8601String(),
    'korisnikId': korisnikId,
    'klijentId': klijentId,
    'uslugaId': uslugaId,
  };
  
  return await insert(request);
}
}
