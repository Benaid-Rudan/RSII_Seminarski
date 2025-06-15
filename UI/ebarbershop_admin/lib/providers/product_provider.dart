import 'dart:convert';
import 'dart:io';

import 'package:ebarbershop_admin/models/product.dart';
import 'package:ebarbershop_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ProductProvider extends BaseProvider<Product> {
  static String? _baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "https://localhost:7126/");
  ProductProvider() : super("Proizvod");
  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      final response = await _client.delete(
        Uri.parse("$_baseUrl/Proizvod/$productId"),
        headers: createHeaders(),
      );

      if (response.statusCode == 200) {
        notifyListeners(); 
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Došlo je do greške pri brisanju proizvoda');
      }
    } catch (e) {
      throw Exception('Greška pri brisanju proizvoda - Postoje narudžbe za ovaj proizvod');
    }
  }

  http.Client get _client {
    if (_baseUrl!.startsWith('https')) {
      final httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return IOClient(httpClient);
    }
    return http.Client();
  }
}