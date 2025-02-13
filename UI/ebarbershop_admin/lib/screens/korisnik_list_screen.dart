// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/korisnik_provider.dart';
import 'package:ebarbershop_admin/screens/korisnik_details.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KorisnikListScreen extends StatefulWidget {
  const KorisnikListScreen({super.key});

  @override
  State<KorisnikListScreen> createState() => _KorisnikListScreenState();
}

class _KorisnikListScreenState extends State<KorisnikListScreen> {
  late KorisnikProvider _korisnikProvider;
  SearchResult<Korisnik>? result;

  TextEditingController _imeController = TextEditingController();
  TextEditingController _prezimeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korisnikProvider = context.read<KorisnikProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title_widget: Text("Lista zaposlenika"),
      child: Column(children: [_buildSearch(), _buildDataListView()]),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                  decoration: InputDecoration(labelText: "Ime"),
                  controller: _imeController)),
          SizedBox(width: 18),
          Expanded(
              child: TextField(
                  decoration: InputDecoration(labelText: "Prezime"),
                  controller: _prezimeController)),
          ElevatedButton(
              onPressed: () async {
                var data = await _korisnikProvider
                    .get(filter: {'ime': _imeController.text});

                setState(() {
                  result = data;
                });
              },
              child: Text("Pretraga")),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => KorisnikDetailsScreen(
                      korisnik: null,
                    ),
                  ),
                );
              },
              child: Text("Dodaj"))
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            const DataColumn(
              label: Expanded(
                child: Text(
                  'ID',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const DataColumn(
              label: Expanded(
                child: Text(
                  'Ime',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const DataColumn(
              label: Expanded(
                child: Text(
                  'Prezime',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
          rows: result?.result
                  .map((Korisnik e) => DataRow(
                          onSelectChanged: (selected) {
                            if (selected == true)
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => KorisnikDetailsScreen(
                                  korisnik: e,
                                ),
                              ));
                          },
                          cells: [
                            DataCell(Text(e.korisnikId.toString() ?? "")),
                            DataCell(Text(e.ime ?? "")),
                            DataCell(Text(e.prezime ?? "")),
                          ]))
                  .toList() ??
              [],
        ),
      ),
    );
  }
}
