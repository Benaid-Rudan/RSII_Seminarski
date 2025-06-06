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

  Future<http.Response> getUslugeByDate(DateTime datum) async {
    Map<String, dynamic> filter = {
      "datum": datum.toIso8601String(), 
    };

    var result =
        await get(filter as Uri); 

    return result;
  }
}
