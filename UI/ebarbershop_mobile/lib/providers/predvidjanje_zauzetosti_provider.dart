import 'dart:convert';
import 'package:ebarbershop_mobile/models/predvidjanje_zauzetosti.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:http/io_client.dart';

class PredvidjanjeZauzetostiProvider extends BaseProvider<PredvidjanjeZauzetosti> {
  PredvidjanjeZauzetostiProvider() : super("PredvidjanjeZauzetosti");

  @override
  PredvidjanjeZauzetosti fromJson(data) {
    return PredvidjanjeZauzetosti.fromJson(data);
  }

  Future<PredvidjanjeZauzetosti> predvidiZauzetost(int korisnikId, DateTime datum) async {
   return await predvidiZauzetost(korisnikId, datum);
    
  }
  
}