import 'dart:convert';
import 'dart:io';

import 'package:ebarbershop_mobile/models/uplata.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class UplataProvider extends BaseProvider<Uplata> {
  UplataProvider() : super("Uplata"); 
  String?_baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "https://10.0.2.2:7286/"); 
  @override
  Uplata fromJson(data) {
    return Uplata.fromJson(data);
  }
  
  @override
  Future<Uplata> insert(dynamic request) async {
  var url = "$_baseUrl" + "Uplata/CreateUplata";  
  var uri = Uri.parse(url);
  var headers = createHeaders();

  var jsonRequest = jsonEncode({
    "iznos": request["iznos"],
    "nacinUplate": request["nacinUplate"],
    "narudzbaId": request["narudzbaId"],
    "datumUplate": request["datumUplate"],
  });

  var ioClient = _createClient(); // Use BaseProvider's client if it's accessible
  var response = await ioClient.post(uri, headers: headers, body: jsonRequest);

  if (isValidResponse(response)) {
    var responseData = jsonDecode(response.body);
    return fromJson(responseData);
  } else {
    throw Exception("Failed to create payment");
  }
}
IOClient _createClient() {
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    return IOClient(httpClient);
  }
}