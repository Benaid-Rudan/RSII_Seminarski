import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Add this to your util.dart file
class Authorization {
  static String? username;
  static String? password;
  static List<String>? roles;
  
  static bool isAdmin() {
    return roles?.contains("Administrator") ?? false;
  }
  
  static bool isEmployee() {
    return roles?.contains("Uposlenik") ?? false;
  }
  
  static void clearCredentials() {
    username = null;
    password = null;
    roles = null;
  }
}

Image imageFromBase64String(String base64Image) {
  return Image.memory(base64Decode(base64Image));
}

String formatNumber(dynamic) {
  var f = NumberFormat('###.00');
  if (dynamic == null) {
    return "";
  }
  return f.format(dynamic);
}
