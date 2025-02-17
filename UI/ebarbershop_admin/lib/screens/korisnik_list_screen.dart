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
                var data = await _korisnikProvider.get(filter: {
                  'ime': _imeController.text,
                  'prezime': _prezimeController.text
                });

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
            const DataColumn(
              label: Expanded(
                child: Text(
                  'Akcije',
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
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool? potvrda = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: Text("Potvrda"),
                                      content: Text(
                                          "Da li ste sigurni da želite obrisati ovog korisnika?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text("Ne"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text("Da"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (potvrda == true) {
                                    try {
                                      // Brisanje korisnika
                                      await _korisnikProvider
                                          .delete(e.korisnikId!);

                                      // Osvežavanje podataka
                                      var data = await _korisnikProvider.get();
                                      setState(() {
                                        result = data;
                                      });
                                    } catch (e) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: Text("Greška"),
                                          content: Text(e.toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ]))
                  .toList() ??
              [],
        ),
      ),
    );
  }
}
