import 'package:ebarbershop_admin/models/rezervacija.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart';
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
  SearchResult<Rezervacija>? result;
  bool _isLoading = false;

  TextEditingController _imePrezimeController = TextEditingController();
  TextEditingController _datumRezervacijeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rezervacijaProvider = context.read<RezervacijaProvider>();
  }

  Future<void> _loadData() async {
    // Učitavanje podataka sa filtrima
    var data = await _rezervacijaProvider.get(filter: {
      "IncludeKorisnik": true,
      "imePrezime": _imePrezimeController.text,
      "datumRezervacije": _datumRezervacijeController.text
    });

    setState(() {
      result = data; // Ažuriranje stanja sa novim podacima
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
                    (Rezervacija e) => DataRow(
                      cells: [
                        DataCell(Text(e.korisnikId?.toString() ?? "")),
                        DataCell(Text(
                          "${e.korisnik?.ime ?? 'Nepoznato'} ${e.korisnik?.prezime ?? ''}",
                        )),
                        DataCell(Text(
                            e.datumRezervacije?.toIso8601String() ?? "N/A")),
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
                                  if (e.rezervacijaId != null) {
                                    // Provjera da terminId nije null
                                    await _rezervacijaProvider
                                        .delete(e.rezervacijaId!);

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
