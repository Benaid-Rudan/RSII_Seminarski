import 'dart:convert';
import 'package:ebarbershop_mobile/models/product.dart';
import 'package:ebarbershop_mobile/models/search_result.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class UslugaProvider extends BaseProvider<Usluga> {
  UslugaProvider() : super("Usluga");

  @override
  Usluga fromJson(data) {
    return Usluga.fromJson(data);
  }

  // Funkcija koja preuzima usluge po datumu
  Future<http.Response> getUslugeByDate(DateTime datum) async {
    // Definisanje filtera kao mapa
    Map<String, dynamic> filter = {
      "datum": datum.toIso8601String(), // Pretvaranje datuma u string
    };

    // Pozivanje funkcije iz BaseProvider i prosleđivanje filtera
    var result =
        await get(filter as Uri); // Dodajte filter kao pozicioni parametar

    return result;
  }
}
