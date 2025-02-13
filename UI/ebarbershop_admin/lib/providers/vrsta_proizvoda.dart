import 'dart:convert';
import 'package:ebarbershop_admin/models/product.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/vrsta_proizvoda.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';
import 'package:ebarbershop_admin/utils/util.dart';
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
