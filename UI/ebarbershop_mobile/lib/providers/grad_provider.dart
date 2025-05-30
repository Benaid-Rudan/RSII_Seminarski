import 'dart:convert';
import 'package:ebarbershop_mobile/models/grad.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';

class GradProvider extends BaseProvider<Grad> {
  GradProvider() : super("Grad"); 

  @override
  Grad fromJson(data) {
    return Grad.fromJson(data);
  }
}
