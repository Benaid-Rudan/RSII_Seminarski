import 'dart:convert';
import 'package:ebarbershop_mobile/models/search_result.dart';
import 'package:ebarbershop_mobile/models/vrsta_proizvoda.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class VrstaProizvodaProvider extends BaseProvider<VrstaProizvoda> {
  VrstaProizvodaProvider() : super("VrstaProizvoda");

  @override
  VrstaProizvoda fromJson(data) {
    // TODO: implement fromJson
    return VrstaProizvoda.fromJson(data);
  }
}
