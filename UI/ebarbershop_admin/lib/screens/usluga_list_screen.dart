import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/usluga.dart';
import 'package:ebarbershop_admin/providers/usluga_provider.dart';
import 'package:ebarbershop_admin/screens/usluga_details.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

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

  // Controllers for the dialog
  TextEditingController _nazivController = TextEditingController();
  TextEditingController _opisController = TextEditingController();
  TextEditingController _cijenaController = TextEditingController();

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
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Usluga",
                  border: OutlineInputBorder(),
                ),
                controller: _uslugaController,
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () async {
                await _loadData();
              },
              child: Text("Pretraga"),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _showUslugaDialog();
              },
              child: Text("Dodaj"),
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
          columns: [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Usluga')),
            DataColumn(label: Text('Opis')),
            DataColumn(label: Text('Cijena')),
            DataColumn(label: Text('Akcije')),
          ],
          rows: result?.result.map((Usluga e) {
                return DataRow(
                  cells: [
                    DataCell(Text(e.uslugaId.toString() ?? "")),
                    DataCell(Text(e.naziv ?? "")),
                    DataCell(Text(e.opis ?? "")),
                    DataCell(Text(e.cijena.toString() ?? "")),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showUslugaDialog(usluga: e),
                          ),
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
                        ],
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

  void _showUslugaDialog({Usluga? usluga}) {
    _nazivController.clear();
    _opisController.clear();
    _cijenaController.clear();

    if (usluga != null) {
      _nazivController.text = usluga.naziv ?? "";
      _opisController.text = usluga.opis ?? "";
      _cijenaController.text = usluga.cijena.toString() ?? "";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(usluga == null ? "Dodaj uslugu" : "Uredi uslugu"),
        content: Container(
          width: 400,
          child: SingleChildScrollView(
            child: FormBuilder(
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'naziv',
                    controller: _nazivController,
                    decoration: InputDecoration(labelText: "Naziv usluge"),
                  ),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'opis',
                    controller: _opisController,
                    decoration: InputDecoration(labelText: "Opis usluge"),
                  ),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'cijena',
                    controller: _cijenaController,
                    decoration: InputDecoration(labelText: "Cijena"),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_nazivController.text.isNotEmpty &&
                  _opisController.text.isNotEmpty &&
                  _cijenaController.text.isNotEmpty) {
                try {
                  if (usluga == null) {
                    // Add new usluga
                    await _uslugaProvider.insert({
                      'naziv': _nazivController.text,
                      'opis': _opisController.text,
                      'cijena': double.parse(_cijenaController.text),
                    });
                  } else {
                    // Update existing usluga
                    await _uslugaProvider.update(usluga.uslugaId!, {
                      'naziv': _nazivController.text,
                      'opis': _opisController.text,
                      'cijena': double.parse(_cijenaController.text),
                    });
                  }
                  await _loadData();
                  Navigator.pop(context);
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
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
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Greška"),
                    content: Text("Sva polja su obavezna."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text("Sačuvaj"),
          ),
        ],
      ),
    );
  }
}
