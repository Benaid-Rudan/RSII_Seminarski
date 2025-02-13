import 'package:ebarbershop_admin/models/rezervacija.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart';
import 'package:ebarbershop_admin/screens/rezervacija_details.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RezervacijaListScreen extends StatefulWidget {
  RezervacijaListScreen({super.key});

  @override
  State<RezervacijaListScreen> createState() => _RezervacijaListScreenState();
}

class _RezervacijaListScreenState extends State<RezervacijaListScreen> {
  late RezervacijaProvider _rezervacijaProvider;
  SearchResult<Rezervacija>? result;

  TextEditingController _imePrezimeController = TextEditingController();
  // TextEditingController _korisnikIdController = TextEditingController();
  TextEditingController _datumRezervacijeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rezervacijaProvider = context.read<RezervacijaProvider>();
  }

  Future<void> _loadData() async {
    // var data = await _rezervacijaProvider.get(filter: {
    //   "IncludeKorisnik": true,
    //   "IncludeUsluga": true,
    //   "imePrezime": _imePrezimeController.text,
    //   "usluga": _uslugaController.text
    // });

    // setState(() {
    //   result = data;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title_widget: Text("Lista rezervacija"),
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
              decoration: InputDecoration(labelText: "ID korisnika"),
              controller: _imePrezimeController,
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: "Datum rezervacije"),
              controller: _datumRezervacijeController,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              var data = await _rezervacijaProvider.get(filter: {
                "IncludeKorisnik": true,
                "IncludeUsluga": true,
                "imePrezime": _imePrezimeController.text,
                "datumRezervacije": _datumRezervacijeController.text
              });

              setState(() {
                result = data;
              });
            },
            child: Text("Pretraga"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      RezervacijaDetailsScreen(rezervacija: null),
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
                  'Ime i prezime',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Datum rezervacije',
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
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RezervacijaDetailsScreen(
                                rezervacija: e,
                              ),
                            ),
                          );
                        }
                      },
                      cells: [
                        DataCell(Text(e.rezervacijaId.toString() ?? "")),
                        DataCell(Text(
                            "${e.korisnik?.ime ?? ''} ${e.korisnik?.prezime ?? ''}")),
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
