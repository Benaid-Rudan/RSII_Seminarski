import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/usluga.dart';
import 'package:ebarbershop_admin/providers/usluga_provider.dart';
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
      color: Colors.blueGrey,
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
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _uslugaController,
                onChanged: (value) {
                  _loadData();
                },
              ),
            ),
            SizedBox(width: 16),
            SizedBox(width: 16),
            if (Authorization.isAdmin())
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
          headingRowColor:
              MaterialStateColor.resolveWith((states) => Colors.black),
          dataRowColor:
              MaterialStateColor.resolveWith((states) => Colors.grey[900]!),
          columns: [
            DataColumn(
                label: Text('ID',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Usluga',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Opis',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Cijena',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            if (Authorization.isAdmin())
            DataColumn(
                label: Text('Akcije',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: result?.result.asMap().entries.map((entry) {
                int index = entry.key;
                Usluga e = entry.value;

                return DataRow(
                  color: MaterialStateColor.resolveWith(
                    (states) =>
                        index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!,
                  ),
                  cells: [
                    DataCell(Text(e.uslugaId.toString() ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(e.naziv ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(e.opis ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(e.cijena.toString() ?? "",
                        style: TextStyle(color: Colors.white))),
                    if (Authorization.isAdmin())
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
                                     ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Usluga uspješno obrisana'),
                                    backgroundColor: Colors.red,
                                  )
                                );
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

  final _formKey = GlobalKey<FormBuilderState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(usluga == null ? "Dodaj uslugu" : "Uredi uslugu"),
      content: Container(
        width: 400,
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'naziv',
                  controller: _nazivController,
                  decoration: InputDecoration(labelText: "Naziv usluge"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Naziv usluge je obavezan';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'opis',
                  controller: _opisController,
                  decoration: InputDecoration(labelText: "Opis usluge"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Opis usluge je obavezan';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'cijena',
                  controller: _cijenaController,
                  decoration: InputDecoration(labelText: "Cijena"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cijena je obavezna';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Unesite validan broj (npr. 10.99)';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Odustani"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              try {
                if (usluga == null) {
                  await _uslugaProvider.insert({
                    'naziv': _nazivController.text,
                    'opis': _opisController.text,
                    'cijena': double.parse(_cijenaController.text),
                  });
                } else {
                  await _uslugaProvider.update(usluga.uslugaId!, {
                    'naziv': _nazivController.text,
                    'opis': _opisController.text,
                    'cijena': double.parse(_cijenaController.text),
                  });
                }
                await _loadData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(usluga == null 
                      ? 'Usluga uspješno dodana' 
                      : 'Usluga uspješno ažurirana'),
                    backgroundColor: Colors.green,
                  )
                );
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
            }
          },
          child: Text("Sačuvaj"),
        ),
      ],
    ),
  );
}
}
