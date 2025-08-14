import 'package:flutter/material.dart';
import 'package:ebarbershop_mobile/models/lista_cekanja.dart';
import 'package:ebarbershop_mobile/providers/lista_cekanja_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyWaitingListScreen extends StatefulWidget {
  const MyWaitingListScreen({Key? key}) : super(key: key);

  @override
  _MyWaitingListScreenState createState() => _MyWaitingListScreenState();
}

class _MyWaitingListScreenState extends State<MyWaitingListScreen> {
  bool isLoading = true;
  List<ListaCekanja> waitingList = [];

  @override
  void initState() {
    super.initState();
    loadWaitingList();
  }

  Future<void> loadWaitingList() async {
    try {
      final provider = context.read<ListaCekanjaProvider>();
      final result = await provider.getMyWaitingList(Authorization.userId!);
      
      setState(() {
        waitingList = result;
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
      final success = await provider.removeFromWaitingList(listaCekanjaId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uspješno uklonjeno s liste čekanja'),
            backgroundColor: Colors.green,
          ),
        );
        await loadWaitingList(); // Refresh list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri uklanjanju s liste čekanja: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moje liste čekanja'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadWaitingList,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : waitingList.isEmpty
              ? Center(
                  child: Text(
                    'Nemate niti jednu listu čekanja',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: waitingList.length,
                  itemBuilder: (context, index) {
                    final item = waitingList[index];
                    return _buildWaitingListItem(item);
                  },
                ),
    );
  }

  Widget _buildWaitingListItem(ListaCekanja item) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.access_time),
        ),
        title: Text(
          '${item.frizer?.ime ?? ''} ${item.frizer?.prezime ?? ''}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usluga: ${item.usluga?.naziv ?? ''}'),
            Text('Datum: ${dateFormat.format(item.zeljeniDatum!)}'),
            if (item.zeljenoVrijeme != null)
            Text('Vrijeme: ${item.zeljenoVrijeme!.substring(0, 5)}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteDialog(item.listaCekanjaId!),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(int listaCekanjaId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ukloni s liste čekanja'),
          content: Text('Da li ste sigurni da želite ukloniti ovu stavku?'),
          actions: <Widget>[
            TextButton(
              child: Text('Otkaži'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Ukloni', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _removeFromWaitingList(listaCekanjaId);
              },
            ),
          ],
        );
      },
    );
  }
}