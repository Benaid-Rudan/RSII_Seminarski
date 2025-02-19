import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/termin.dart';
import 'package:ebarbershop_admin/providers/termin_provider.dart';
import 'package:ebarbershop_admin/screens/termin_details.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TerminListScreen extends StatefulWidget {
  TerminListScreen({super.key});

  @override
  State<TerminListScreen> createState() => _TerminListScreenState();
}

class _TerminListScreenState extends State<TerminListScreen> {
  late TerminProvider _terminProvider;
  SearchResult<Termin>? result;

  TextEditingController _imePrezimeController = TextEditingController();
  TextEditingController _datumRezervacijeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _terminProvider = context.read<TerminProvider>();
  }

  Future<void> _loadData() async {
    // Učitavanje podataka sa filtrima
    var data = await _terminProvider.get(filter: {
      "IncludeKorisnik": true,
      "IncludeRezervacija": true,
      "imePrezime": _imePrezimeController.text,
      "Datum": _datumRezervacijeController.text
    });

    setState(() {
      result = data; // Ažuriranje stanja sa novim podacima
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title_widget: Text("Lista termina"),
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
              decoration: InputDecoration(labelText: "Ime i prezime"),
              controller: _imePrezimeController,
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: "Datum termina"),
              controller: _datumRezervacijeController,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Pokrećemo pretragu
              await _loadData(); // Pozivamo metodu za učitavanje podataka sa filtrima
            },
            child: Text("Pretraga"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TerminDetailsScreen(termin: null),
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
                  'ID',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Frizer',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Datum termina',
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
                    (Termin e) => DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TerminDetailsScreen(
                                termin: e,
                              ),
                            ),
                          );
                        }
                      },
                      cells: [
                        DataCell(Text(e.terminId.toString() ?? "")),
                        DataCell(Text(
                            "${e.korisnik?.ime ?? ''} ${e.korisnik?.prezime ?? ''}")),
                        DataCell(Text(e.vrijeme?.toIso8601String() ?? "")),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool? potvrda = await showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text("Potvrda"),
                                  content: Text(
                                      "Da li ste sigurni da želite obrisati ovaj termin?"),
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
                                  if (e.terminId != null) {
                                    // Provjera da terminId nije null
                                    await _terminProvider.delete(e.terminId!);

                                    // Osvježavanje podataka
                                    await _loadData(); // Pozivanje metode za ponovno učitavanje podataka
                                  } else {
                                    throw Exception("Termin ID je null.");
                                  }
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
