import 'dart:convert';
import 'package:ebarbershop_mobile/models/search_result.dart';
import 'package:ebarbershop_mobile/models/termin.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class TerminProvider extends BaseProvider<Termin> {
  TerminProvider() : super("Termin");

  @override
  Termin fromJson(data) {
    // TODO: implement fromJson
    return Termin.fromJson(data);
  }
}
