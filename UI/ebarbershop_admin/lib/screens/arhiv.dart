import 'package:ebarbershop_admin/models/rezervacija.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArhivaListScreen extends StatefulWidget {
  ArhivaListScreen({super.key});

  @override
  State<ArhivaListScreen> createState() => _ArhivaListScreenState();
}

class _ArhivaListScreenState extends State<ArhivaListScreen> {
  late RezervacijaProvider _rezervacijaProvider;
  SearchResult<Rezervacija>? result;
  bool _isLoading = false;

  TextEditingController _datumController = TextEditingController();
  TextEditingController _uslugaController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rezervacijaProvider = context.read<RezervacijaProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    var data = await _rezervacijaProvider.get(filter: {
      "IncludeUsluga": true,
      "datumRezervacije": _datumController.text,
      "usluga": _uslugaController.text
    });

    setState(() {
      result = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildSearch(),
      _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildDataListView()
    ]);
  }

  Widget _buildSearch() {
    return Card(
      color: Colors.blueGrey,
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Datum obavljene usluge",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _datumController,
                onChanged: (value) {
                  _loadData();
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Naziv usluge",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _uslugaController,
                onChanged: (value) {
                  _loadData();
                },
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor:
              MaterialStateColor.resolveWith((states) => Colors.black),
          dataRowColor:
              MaterialStateColor.resolveWith((states) => Colors.grey[900]!),
          columns: [
            DataColumn(
              label: Expanded(
                child: Text(
                  'Datum',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Usluga',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          rows: result?.result.asMap().entries.map((entry) {
                int index = entry.key;
                Rezervacija e = entry.value;

                return DataRow(
                  color: MaterialStateColor.resolveWith(
                    (states) =>
                        index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!,
                  ),
                  cells: [
                    DataCell(Text(e.datumRezervacije?.toIso8601String() ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(e.usluga?.naziv ?? "",
                        style: TextStyle(color: Colors.white))),
                  ],
                );
              }).toList() ??
              [],
        ),
      ),
    );
  }
}
