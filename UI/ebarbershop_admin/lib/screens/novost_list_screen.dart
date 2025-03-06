import 'package:ebarbershop_admin/models/novost.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/novost_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class NovostListScreen extends StatefulWidget {
  NovostListScreen({super.key});

  @override
  State<NovostListScreen> createState() => _NovostListScreenState();
}

class _NovostListScreenState extends State<NovostListScreen> {
  late NovostProvider _novostProvider;
  SearchResult<Novost>? result;
  bool _isLoading = false;

  TextEditingController _tekstController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _novostProvider = context.read<NovostProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    var data = await _novostProvider.get(filter: {
      "naslov": _tekstController.text,
    });

    setState(() {
      result = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearch(),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : _buildDataListView(),
      ],
    );
  }

  Widget _buildSearch() {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Tekst novosti",
                  border: OutlineInputBorder(),
                ),
                controller: _tekstController,
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
                _showNovostDialog(context);
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
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
                label:
                    Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Slika',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Tekst',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Akcije',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: result?.result
                  .map((Novost e) => DataRow(
                        onSelectChanged: (selected) {
                          if (selected == true) {
                            _showNovostDialog(context, novost: e);
                          }
                        },
                        cells: [
                          DataCell(Text(e.novostId.toString() ?? "")),
                          DataCell(e.slika != null
                              ? Image.network(e.slika!,
                                  width: 50, height: 50, fit: BoxFit.cover)
                              : Icon(Icons.image, color: Colors.grey)),
                          DataCell(Text(e.sadrzaj ?? "")),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _showNovostDialog(context, novost: e);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    bool? potvrda = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: Text("Potvrda"),
                                        content: Text(
                                            "Da li ste sigurni da želite obrisati ovu novost?"),
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
                                      await _novostProvider.delete(e.novostId!);
                                      _loadData();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ))
                  .toList() ??
              [],
        ),
      ),
    );
  }

  void _showNovostDialog(BuildContext context, {Novost? novost}) {
    final _formKey = GlobalKey<FormBuilderState>();
    Map<String, dynamic> _initialValue = {
      'novostId': novost?.novostId,
      'naslov': novost?.naslov,
      'sadrzaj': novost?.sadrzaj,
      'datumObjave': novost?.datumObjave != null ? novost?.datumObjave : null,
      'slika': novost?.slika,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(novost == null ? "Dodaj novost" : "Uredi novost"),
        content: Container(
          width: 400,
          height: 380,
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              initialValue: _initialValue,
              child: Column(
                children: [
                  FormBuilderTextField(
                      name: "naslov",
                      decoration: InputDecoration(labelText: "Naslov")),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: "sadrzaj",
                    decoration: InputDecoration(labelText: "Sadržaj"),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  SizedBox(height: 8),
                  FormBuilderDateTimePicker(
                      name: "datumObjave",
                      decoration: InputDecoration(labelText: "Datum objave")),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                      name: "slika",
                      decoration: InputDecoration(labelText: "Slika URL")),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Odustani")),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            final formData = _formKey.currentState?.value;
                            try {
                              if (novost == null) {
                                await _novostProvider.insert(
                                  {
                                    'naslov': formData?['naslov'],
                                    'sadrzaj': formData?['sadrzaj'],
                                    'datumObjave':
                                        (formData?['datumObjave'] as DateTime?)
                                            ?.toIso8601String(),
                                    'slika': formData?['slika']
                                  },
                                );
                              } else {
                                await _novostProvider.update(novost.novostId!, {
                                  'naslov': formData?['naslov'],
                                  'sadrzaj': formData?['sadrzaj'],
                                  'datumObjave':
                                      (formData?['datumObjave'] as DateTime?)
                                          ?.toIso8601String(),
                                  'slika': formData?['slika']
                                });
                              }
                              await _loadData();
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
                            _loadData();
                            Navigator.pop(context);
                          }
                        },
                        child: Text("Sačuvaj"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
