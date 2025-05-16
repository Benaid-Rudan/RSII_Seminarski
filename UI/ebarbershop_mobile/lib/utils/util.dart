import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Authorization {
  static String? username;
  static String? password;
  static int? userId;
  static String? ime;
  static String? prezime;
  static String? email;
  static String? slika;
  static String? gradId;

 static String? localImage;

  
  static void clear() {
    username = null;
    password = null;
    userId = null;
    ime = null;
    prezime = null;
    email = null;
    slika = null;
    gradId = null;
    localImage = null;
  }
}

Image imageFromBase64String(String base64String) {
  return Image.memory(base64Decode(base64String));
}

Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}

String base64String(Uint8List data) {
  return base64Encode(data);
}

String formatNumber(dynamic) {
   var f = NumberFormat('#,##0.00', 'bs_BA');
  if (dynamic == null) {
    return "";
  }
  
  return f.format(dynamic);
}