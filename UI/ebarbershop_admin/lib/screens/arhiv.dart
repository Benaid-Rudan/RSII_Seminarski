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

  TextEditingController _datumController = TextEditingController();
  TextEditingController _uslugaController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rezervacijaProvider = context.read<RezervacijaProvider>();
  }

  Future<void> _loadData() async {
    var data = await _rezervacijaProvider.get(filter: {
      "IncludeUsluga": true,
      "datumRezervacije": _datumController.text,
      "usluga": _uslugaController.text
    });

    setState(() {
      result = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title_widget: Text("Arhiva obavljenih usluga"),
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildSearch(),
            _buildDataListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: "Datum obavljene usluge"),
              controller: _datumController,
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: "Naziv usluge"),
              controller: _uslugaController,
            ),
          ),
          ElevatedButton(
            onPressed: _loadData,
            child: Text("Pretraga"),
          ),
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(
              label: Expanded(
                child: Text(
                  'Datum',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Usluga',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
          rows: result?.result
                  .map(
                    (Rezervacija e) => DataRow(
                      cells: [
                        DataCell(
                            Text(e.datumRezervacije?.toIso8601String() ?? "")),
                        DataCell(Text(e.usluga?.naziv ?? "")),
                      ],
                    ),
                  )
                  .toList() ??
              [],
        ),
      ),
    );
  }
}
