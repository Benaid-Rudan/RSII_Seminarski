import 'package:ebarbershop_admin/models/rezervacija.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/termin.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart';
import 'package:ebarbershop_admin/providers/termin_provider.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TerminListScreen extends StatefulWidget {
  TerminListScreen({super.key});

  @override
  State<TerminListScreen> createState() => _TerminListScreenState();
}

class _TerminListScreenState extends State<TerminListScreen> {
  late RezervacijaProvider _rezervacijaProvider;
  late TerminProvider _terminProvider;

  SearchResult<Termin>? result;
  bool _isLoading = false;

  TextEditingController _imePrezimeController = TextEditingController();
  TextEditingController _datumRezervacijeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rezervacijaProvider = context.read<RezervacijaProvider>();
    _terminProvider = context.read<TerminProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    var data = await _terminProvider.get(filter: {
      "IncludeKorisnik": true,
      "IncludeRezervacija": true,
      "isBooked": true,
      "imePrezime": _imePrezimeController.text,
    });
    var termin = await _terminProvider.get(
    );
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
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Ime i prezime",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _imePrezimeController,
                onChanged: (value) {
                  _loadData();
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Datum termina",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _datumRezervacijeController,
                onChanged: (value) {
                  _loadData();
                },
              ),
            ),
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
              label: Text(
                'ID',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Frizer',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Datum termina',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const DataColumn(
              label: Text(
                'Akcije',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: result?.result.asMap().entries.map((entry) {
                int index = entry.key;
                Termin e = entry.value;

                return DataRow(
                  color: MaterialStateColor.resolveWith(
                    (states) =>
                        index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!,
                  ),
                  cells: [
                    DataCell(Text(e.korisnik?.korisnikId.toString() ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(
                        "${e.korisnik?.ime ?? 'Nepoznato'} ${e.korisnik?.prezime ?? ''}",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(
                        e.vrijeme?.toIso8601String() ?? "N/A",
                        style: TextStyle(color: Colors.white))),
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
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("Da"),
                                ),
                              ],
                            ),
                          );

                          if (potvrda == true) {
                            try {
                              if (e.terminId != null) {
                                await _terminProvider
                                    .delete(e.terminId!);

                                await _loadData();
                              } else {
                                throw Exception("Termin ID je null.");
                              }
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text("Greška"),
                                  content: Text(e.toString()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
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
                );
              }).toList() ??
              [],
        ),
      ),
    );
  }
}
