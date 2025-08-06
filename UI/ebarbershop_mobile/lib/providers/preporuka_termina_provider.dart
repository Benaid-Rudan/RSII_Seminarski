
import 'dart:convert';
import 'package:ebarbershop_mobile/models/preporuka_termina.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:http/io_client.dart';

class PreporukaTerminaProvider extends BaseProvider<PreporukaTermina> {
  PreporukaTerminaProvider() : super("PreporukaTermina");

  @override
  PreporukaTermina fromJson(data) {
    return PreporukaTermina.fromJson(data);
  }

  Future<List<PreporukaTermina>> generirajPreporuke(int klijentId, int uslugaId) async {
    return await generirajPreporuke(klijentId, uslugaId);

  }

  Future<bool> prihvatiPreporuku(int preporukaId) async {
    return await prihvatiPreporuku(preporukaId);

  }

}