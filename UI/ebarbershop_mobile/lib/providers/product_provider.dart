import 'dart:convert';
import 'dart:io';
import 'package:ebarbershop_mobile/models/product.dart';
import 'package:ebarbershop_mobile/models/search_result.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class ProductProvider extends BaseProvider<Product> {
  
  ProductProvider() : super("Proizvod");

  @override
  Product fromJson(data) {
    // TODO: implement fromJson
    return Product.fromJson(data);
  }
  Future<List<Product>> getRecommended() async {
    return await super.getRecommended();
  }
  
}
