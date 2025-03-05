import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/usluga.dart';
import 'package:ebarbershop_admin/providers/usluga_provider.dart';
import 'package:ebarbershop_admin/screens/usluga_details.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UslugaListScreen extends StatefulWidget {
  String? korisnikId;
  String? uslugaId;
  String? datumRezervacije;

  UslugaListScreen(
      {super.key, this.korisnikId, this.uslugaId, this.datumRezervacije});

  @override
  State<UslugaListScreen> createState() => _UslugaListScreenState();
}

class _UslugaListScreenState extends State<UslugaListScreen> {
  late UslugaProvider _uslugaProvider;
  SearchResult<Usluga>? result;
  bool _isLoading = false;

  TextEditingController _uslugaController = TextEditingController();
  TextEditingController _datumRezervacijeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _uslugaProvider = context.read<UslugaProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    var data = await _uslugaProvider.get(filter: {
      "naziv": _uslugaController.text,
      "uslugaId": widget.uslugaId,
      "datumRezervacije": widget.datumRezervacije,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: "Usluga"),
              controller: _uslugaController,
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
                  builder: (context) => UslugaDetailsScreen(usluga: null),
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
                  'Usluga',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Opis',
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
            const DataColumn(
              label: Expanded(
                child: Text(
                  'Akcije',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
          rows: result?.result.map(
                (Usluga e) {
                  // Da bismo dobili datum termina, moramo koristiti Rezervacija
                  // String terminDatum = "Nema datuma"; // Defaultna vrednost

                  // if (e.rezervacije != null && e.rezervacije!.isNotEmpty) {
                  //   // Pretpostavljamo da Rezervacija može imati termine
                  //   var termin = e.rezervacije!.first.termini?.firstWhere(
                  //     (t) =>
                  //         t.isBooked ==
                  //         true, // Only pick `true` values for `isBooked`
                  //     orElse: () => Termin(
                  //       vrijeme:
                  //           DateTime.now(), // Defaultni termin ako nema termina
                  //     ),
                  //   );

                  //   terminDatum =
                  //       termin?.vrijeme?.toIso8601String() ?? "Nema datuma";
                  // }

                  return DataRow(
                    onSelectChanged: (selected) {
                      if (selected == true) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UslugaDetailsScreen(
                              usluga: e,
                            ),
                          ),
                        );
                      }
                    },
                    cells: [
                      DataCell(Text(e.uslugaId.toString() ?? "")),
                      DataCell(Text(e.naziv ?? "")),
                      DataCell(Text(e.opis ?? "")),
                      DataCell(Text(e.cijena.toString() ?? "")),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? potvrda = await showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text("Potvrda"),
                                content: Text(
                                    "Da li ste sigurni da želite obrisati ovu uslugu?"),
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
                                if (e.uslugaId != null) {
                                  await _uslugaProvider.delete(e.uslugaId!);

                                  await _loadData();
                                } else {
                                  throw Exception("Usluga ID je null.");
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
                },
              ).toList() ??
              [],
        ),
      ),
    );
  }
}
