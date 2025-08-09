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

  Future<List<PreporukaTermina>> generirajPreporukeZaKlijenta(int klijentId, int uslugaId) async {
    return await super.generirajPreporuke(klijentId, uslugaId);
  }

  Future<bool> prihvatiPreporukuTermina(int preporukaId) async {
    return await super.prihvatiPreporuku(preporukaId);
  }
}