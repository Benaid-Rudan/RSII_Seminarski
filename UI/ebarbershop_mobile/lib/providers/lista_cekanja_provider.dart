import 'package:ebarbershop_mobile/models/lista_cekanja.dart';
import 'package:ebarbershop_mobile/models/search_result.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';

class ListaCekanjaProvider extends BaseProvider<ListaCekanja> {
  ListaCekanjaProvider() : super("ListaCekanja");

  @override
  ListaCekanja fromJson(data) => ListaCekanja.fromJson(data);

  Future<ListaCekanja> joinWaitingList(ListaCekanjaInsertRequest request) async {
        return await super.joinWaitingList(request);

  }

  Future<List<ListaCekanja>> getMyWaitingList(int klijentId) async {
        return await super.getMyWaitingList(klijentId);
    
  }

  Future<bool> removeFromWaitingList(int listaCekanjaId) async {
        return await super.removeFromWaitingList(listaCekanjaId);
    
  }
  @override
  Future<List<ListaCekanja>> getByFrizerAndDate({required int frizerId, required DateTime datum}) {
    return super.getByFrizerAndDate(frizerId: frizerId, datum: datum);
  }
}