import 'dart:convert';
import 'package:ebarbershop_mobile/models/lista_cekanja.dart';
import 'package:ebarbershop_mobile/models/predvidjanje_zauzetosti.dart';
import 'package:ebarbershop_mobile/models/preporuka_termina.dart';
import 'package:ebarbershop_mobile/models/search_result.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:ebarbershop_mobile/models/product.dart';
import 'package:http/io_client.dart';  
import 'dart:io';  
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';  

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
     _baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "https://10.0.2.2:7286/");  
     
  }

  IOClient _createClient() {
    HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      print('Prihvaćam certifikat za $host:$port');
      return true; 
    };
  return IOClient(httpClient);
  }

  Future<T> login(String username, String password) async {
  var url = "$_baseUrl$_endpoint/Authenticate";
  var uri = Uri.parse(url);
  
  String basicAuth = "Basic ${base64Encode(utf8.encode('$username:$password'))}";
  var headers = {
    "Content-Type": "application/json",
    "Authorization": basicAuth
  };
  
  var ioClient = _createClient();
  var response = await ioClient.get(uri, headers: headers);
  
  if (isValidResponse(response)) {
    var data = jsonDecode(response.body);
    return fromJson(data);
    } else {
    throw Exception("Authentication failed");
    }
  }
  
  Future<SearchResult<T>> get({dynamic filter}) async {
  var url = "$_baseUrl$_endpoint";
  if (filter != null) {
    var queryString = getQueryString(filter);
    url = "$url?$queryString";
  }
  var uri = Uri.parse(url);
  var headers = createHeaders();

  
  var ioClient = _createClient();
  var response = await ioClient.get(uri, headers: headers);


  if (isValidResponse(response)) {
    try {
      var data = jsonDecode(response.body);
      
      if (data is List) {
        var result = SearchResult<T>();
        result.count = data.length;
        for (var item in data) {
          result.result.add(fromJson(item));
        }
        return result;
      } else if (data is Map<String, dynamic>) {
        var result = SearchResult<T>();
        result.count = 1;
        result.result.add(fromJson(data));
        return result;
      } else {
        throw Exception("Neočekivani format odgovora");
      }
    } catch (e) {
      debugPrint("Greška pri parsiranju: $e");
      throw Exception("Greška pri parsiranju API odgovora");
    }
  } else {
    throw Exception("Neuspješan API poziv");
  }
}
// Future<List<T>> getByFrizerAndDate({
//   required int frizerId,
//   required DateTime datum,
// }) async {
//   var url = "$_baseUrl$_endpoint/frizer/$frizerId?datum=${DateFormat('yyyy-MM-dd').format(datum)}";
//   var uri = Uri.parse(url);
//   var headers = createHeaders();

//   var ioClient = _createClient();
//   var response = await ioClient.get(uri, headers: headers);

//   if (isValidResponse(response)) {
//     var data = jsonDecode(response.body) as List;
//     return data.map((item) => fromJson(item)).toList();
//   } else {
//     throw Exception('Failed to load waiting list');
//   }
// }


Future<T> joinWaitingList(ListaCekanjaInsertRequest request) async {
  var url = "$_baseUrl$_endpoint";
  var uri = Uri.parse(url);
  var headers = createHeaders();
  var jsonRequest = jsonEncode(request.toJson());

  print('Sending to ${uri.toString()} with body: $jsonRequest'); // Dodajte logging

  var ioClient = _createClient();
  var response = await ioClient.post(uri, headers: headers, body: jsonRequest);

  if (response.statusCode == 400) {
    print('Bad request details: ${response.body}');
    throw Exception(response.body);
  }

  if (isValidResponse(response)) {
    var data = jsonDecode(response.body);
    return fromJson(data);
  } else {
    throw Exception("Failed to join waiting list: ${response.statusCode}");
  }
}

Future<List<T>> getMyWaitingList(int klijentId) async {
    var url = "$_baseUrl$_endpoint/my-waiting-list";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var ioClient = _createClient();
    var response = await ioClient.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List;
      return data.map((x) => fromJson(x)).toList();
    } else {
      throw Exception("Failed to get waiting list");
    }
  }
Future<bool> removeFromWaitingList(int listaCekanjaId) async {
    var url = "$_baseUrl$_endpoint/$listaCekanjaId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var ioClient = _createClient();
    var response = await ioClient.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      return true;
    } else {
      throw Exception("Failed to remove from waiting list");
    }
  }

  Future<List<Product>> recommend(int userId) async {
  var url = "${BaseProvider._baseUrl}$_endpoint/recommend?userId=$userId";
  print("Calling recommended products API: $url");
  var uri = Uri.parse(url);
  var headers = createHeaders();

  var ioClient = _createClient();
  var response = await ioClient.get(uri, headers: headers);

  if (isValidResponse(response)) {
    var data = jsonDecode(response.body) as List;
    return data.map((x) => Product.fromJson(x)).toList();
  } else {
    throw Exception("Failed to load recommended products");
  }
}

  Future<T> getById(int id) async {
  var url = "$_baseUrl$_endpoint/$id";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  var ioClient = _createClient();
  var response = await ioClient.get(uri, headers: headers);

  if (isValidResponse(response)) {
    var data = jsonDecode(response.body);
    return fromJson(data);
  } else {
    throw Exception("Failed to fetch resource with ID $id");
  }
}

  Future<T> insert(dynamic request) async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var jsonRequest = jsonEncode(request);

    var ioClient = _createClient();
    var response = await ioClient.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<T> update(int id, Map<String, dynamic> value,
      {dynamic request}) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var jsonRequest = jsonEncode(request ?? value);

    var ioClient = _createClient();
    var response = await ioClient.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<void> delete(int id) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var ioClient = _createClient();
    var response = await ioClient.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      notifyListeners(); 
    } else {
      throw Exception("Failed to delete");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Unauthorized");
    } else {
      print("Response: ${response.statusCode}, Body: ${response.body}");
      throw new Exception("Something bad happened please try again");
    }
  }
  Future<T> predvidiZauzetost(int korisnikId, DateTime datum) async {
   var url = "$_baseUrl$_endpoint/predvidi/$korisnikId?datum=${datum.toIso8601String()}";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  var ioClient = _createClient();
  var response = await ioClient.get(uri, headers: headers);

  if (isValidResponse(response)) {
    var data = jsonDecode(response.body);
    
    // Handle both List and Map responses
    if (data is List) {
      if (data.isNotEmpty) {
        return fromJson(data.first); // Take first item if it's a list
      } else {
        throw Exception("No prediction data available");
      }
    } else if (data is Map<String, dynamic>) {
      return fromJson(data);
    } else {
      throw Exception("Unexpected response format");
    }
  } else {
    throw Exception("Greška pri dohvatanju predviđanja zauzetosti");
  }
  }
  Future<List<PreporukaTermina>> generirajPreporuke(int klijentId, int uslugaId) async {
    var url = "$_baseUrl$_endpoint/generiraj/$klijentId/$uslugaId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var ioClient = _createClient();
    var response = await ioClient.post(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List;
      return data.map((x) => PreporukaTermina.fromJson(x)).toList();
    } else {
      throw Exception("Greška pri generiranju preporuka");
    }
  }

  Future<bool> prihvatiPreporuku(int preporukaId) async {
    var url = "$_baseUrl$_endpoint/prihvati/$preporukaId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var ioClient = _createClient();
    var response = await ioClient.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data is bool ? data : true;
    } else {
      throw Exception("Greška pri prihvatanju preporuke");
    }
  }
  Map<String, String> createHeaders() {
    var headers = {
      'Content-Type': 'application/json',
    };

    if (Authorization.username != null && Authorization.password != null) {
      final credentials = '${Authorization.username}:${Authorization.password}';
      final encoded = base64Encode(utf8.encode(credentials));
      headers['Authorization'] = 'Basic $encoded';
    }

    return headers;
  }
}



String getQueryString(Map params,
    {String prefix = '&', bool inRecursion = false}) {
  String query = '';
  params.forEach((key, value) {
    if (inRecursion) {
      if (key is int) {
        key = '[$key]';
      } else if (value is List || value is Map) {
        key = '.$key';
      } else {
        key = '.$key';
      }
    }
    if (value is String || value is int || value is double || value is bool) {
      var encoded = value;
      if (value is String) {
        encoded = Uri.encodeComponent(value);
      }
      query += '$prefix$key=$encoded';
    } else if (value is DateTime) {
      query += '$prefix$key=${(value as DateTime).toIso8601String()}';
    } else if (value is List || value is Map) {
      if (value is List) value = value.asMap();
      value.forEach((k, v) {
        query +=
            getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
      });
    }
  });
  return query;
}
