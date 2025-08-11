import 'package:ebarbershop_mobile/models/lista_cekanja.dart';
import 'package:ebarbershop_mobile/providers/lista_cekanja_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';

class WaitingListScreen extends StatefulWidget {
  const WaitingListScreen({Key? key}) : super(key: key);

  @override
  _WaitingListScreenState createState() => _WaitingListScreenState();
}

class _WaitingListScreenState extends State<WaitingListScreen> {
  bool isLoading = true;
  List<ListaCekanja> waitingListItems = [];

  @override
  void initState() {
    super.initState();
    _loadWaitingList();
  }

  Future<void> _loadWaitingList() async {
    try {
      final provider = context.read<ListaCekanjaProvider>();
      final items = await provider.getMyWaitingList(Authorization.userId!);
      setState(() {
        waitingListItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri učitavanju liste čekanja: $e')),
      );
    }
  }

  Future<void> _removeFromWaitingList(int listaCekanjaId) async {
    try {
      final provider = context.read<ListaCekanjaProvider>();
      await provider.removeFromWaitingList(listaCekanjaId);
      await _loadWaitingList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uspješno uklonjeno sa liste čekanja')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri uklanjanju sa liste čekanja: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moja lista čekanja'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : waitingListItems.isEmpty
              ? Center(
                  child: Text(
                    'Nemate aktivnih stavki na listi čekanja',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: waitingListItems.length,
                  itemBuilder: (context, index) {
                    final item = waitingListItems[index];
                    return _buildWaitingListItem(item);
                  },
                ),
    );
  }

  Widget _buildWaitingListItem(ListaCekanja item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.access_time, color: _getStatusColor(item.status)),
        title: Text('${item.usluga?.naziv ?? 'Usluga'} kod ${item.frizer?.ime ?? 'Frizer'}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datum: ${DateFormat('dd.MM.yyyy').format(item.zeljeniDatum!)}'),
            if (item.zeljeniDatum != null)
              Text('Vrijeme: ${DateFormat('HH:mm').format(item.zeljeniDatum!)}'),
              Text('Status: ${_getStatusText(item.status)}'),
            Text('Prioritet: ${item.prioritet}/100'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.cancel, color: Colors.red),
          onPressed: () => _removeFromWaitingList(item.listaCekanjaId!),
        ),
      ),
    );
  }

  Color _getStatusColor(StatusCekanja? status) {
    switch (status) {
      case StatusCekanja.Aktivna:
        return Colors.blue;
      case StatusCekanja.Notificirana:
        return Colors.orange;
      case StatusCekanja.Prihvacena:
        return Colors.green;
      case StatusCekanja.Istekla:
        return Colors.grey;
      case StatusCekanja.Otkazana:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _getStatusText(StatusCekanja? status) {
    switch (status) {
      case StatusCekanja.Aktivna:
        return 'Aktivna';
      case StatusCekanja.Notificirana:
        return 'Notificirana';
      case StatusCekanja.Prihvacena:
        return 'Prihvaćena';
      case StatusCekanja.Istekla:
        return 'Istekla';
      case StatusCekanja.Otkazana:
        return 'Otkazana';
      default:
        return 'Nepoznat status';
    }
  }
}