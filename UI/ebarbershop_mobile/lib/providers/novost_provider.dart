import 'dart:convert';
import 'package:ebarbershop_mobile/models/novost.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';

class NovostProvider extends BaseProvider<Novost> {
  NovostProvider() : super("Novost"); 

  @override
  Novost fromJson(data) {
    return Novost.fromJson(data);
  }
}
