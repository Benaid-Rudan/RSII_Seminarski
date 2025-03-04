import 'package:ebarbershop_admin/models/narudzba.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/narudzba_provider.dart';
import 'package:ebarbershop_admin/screens/narudzba_details.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NarudzbaListScreen extends StatefulWidget {
  NarudzbaListScreen({super.key});

  @override
  State<NarudzbaListScreen> createState() => _NarudzbaListScreenState();
}

class _NarudzbaListScreenState extends State<NarudzbaListScreen> {
  late NarudzbaProvider _narudzbaProvider;
  SearchResult<Narudzba>? result;
  bool _isLoading = false;

  TextEditingController _korisnikIdController = TextEditingController();
  TextEditingController _narudzbaIdController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _narudzbaProvider = context.read<NarudzbaProvider>();
  }

  Future<void> _loadData() async {
    // Učitavanje podataka sa filtrima
    var data = await _narudzbaProvider.get(filter: {
      "IncludeNarudzbaProizvodi": true,
      "KorisnikId": _korisnikIdController.text,
      "NarudzbaId": _narudzbaIdController.text
    });

    setState(() {
      result = data;
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: "Kupac Id"),
              controller: _korisnikIdController,
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: "Narudzba Id"),
              controller: _narudzbaIdController,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _loadData();
            },
            child: Text("Pretraga"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NarudzbaDetailsScreen(narudzba: null),
                ),
              );
            },
            child: Text("Dodaj"),
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
                  'Narudzba Id',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Kupac Id',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Proizvod',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Cijena',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Datum i vrijeme',
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
                  .map(
                    (Narudzba e) => DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NarudzbaDetailsScreen(
                                narudzba: e,
                              ),
                            ),
                          );
                        }
                      },
                      cells: [
                        DataCell(Text("${e.narudzbaId ?? ''}")),
                        DataCell(Text("${e.korisnikId ?? ''}")),
                        DataCell(
                          Text(
                            e.narudzbaProizvodis
                                    ?.map((np) => np.proizvod?.naziv)
                                    .join(', ') ??
                                "",
                          ),
                        ),
                        DataCell(Text(
                          e.narudzbaProizvodis
                                  ?.map((np) =>
                                      np.proizvod?.cijena?.toStringAsFixed(2))
                                  .join(', ') ??
                              "",
                        )),
                        DataCell(Text(
                            e.datum != null ? e.datum!.toIso8601String() : "")),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool? potvrda = await showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text("Potvrda"),
                                  content: Text(
                                      "Da li ste sigurni da želite obrisati ovu narudžbu?"),
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
                                  await _narudzbaProvider.delete(e.narudzbaId!);

                                  // Automatski učitajte nove podatke nakon brisanja
                                  await _loadData();
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
