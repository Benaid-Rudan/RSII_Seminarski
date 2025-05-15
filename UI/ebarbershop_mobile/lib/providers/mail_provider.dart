import 'dart:convert';

import 'package:ebarbershop_mobile/models/mail_object.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MailProvider with ChangeNotifier {
  static String? _baseUrl;
  MailProvider() {
    _baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "http://10.0.2.2:5191/");
  }
  Map<String, String> createHeaders() {
    String username = Authorization.username ?? "";
    String password = Authorization.password ?? "";
    print("passed creds: $username $password");

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };
    return headers;
  }
  Future<void> sendMail(MailObject mail) async {
    var url = "$_baseUrl" + "Mail";

    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(mail.toJson()),
      );

      if (response.statusCode == 200) {
        print("Mail sent to queue successfully");
      } else {
        throw Exception("Failed to send mail to queue");
      }
    } catch (e) {
      print("Error sending mail: $e");
      throw Exception("Error sending mail: $e");
    }
  }
}