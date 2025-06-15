import 'dart:convert';
import 'package:ebarbershop_admin/models/product.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/usluga.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';
import 'package:ebarbershop_admin/utils/util.dart';
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
