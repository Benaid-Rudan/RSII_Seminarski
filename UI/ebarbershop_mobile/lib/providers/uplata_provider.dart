import 'dart:convert';
import 'dart:io';

import 'package:ebarbershop_mobile/models/uplata.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class UplataProvider extends BaseProvider<Uplata> {
  UplataProvider() : super("Uplata"); 
  String?_baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "http://10.0.2.2:7126/"); 
  @override
  Uplata fromJson(data) {
    return Uplata.fromJson(data);
  }
 
}