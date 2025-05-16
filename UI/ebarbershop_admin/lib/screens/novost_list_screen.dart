import 'dart:convert';
import 'dart:io';

import 'package:ebarbershop_admin/models/novost.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/novost_provider.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  TextEditingController _slikaController = TextEditingController();
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
      color: Colors.blueGrey,
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
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _tekstController,
                onChanged: (value) {
                  _loadData();
                },
              ),
            ),
            SizedBox(width: 16),
            if (Authorization.isAdmin())
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
                label: Text('Slika',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Tekst',
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
                Novost e = entry.value;

                return DataRow(
                  color: MaterialStateColor.resolveWith(
                    (states) =>
                        index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!,
                  ),
                  cells: [
                    DataCell(Text(e.novostId.toString() ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(e.slika != null && e.slika!.isNotEmpty
                        ? (e.slika!.startsWith('http')
                            ? Image.network(
                                e.slika!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Image.memory(base64Decode(e.slika!),
                                width: 50, height: 50, fit: BoxFit.cover))
                        : Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.white,
                          )),
                    DataCell(Text(e.sadrzaj ?? "",
                        style: TextStyle(color: Colors.white))),
                    if(Authorization.isAdmin())
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
                                builder: (BuildContext context) => AlertDialog(
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
                                 ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Novost uspješno obrisana'),
                                    backgroundColor: Colors.red,
                                  )
                                );
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

  void _showNovostDialog(BuildContext context, {Novost? novost}) {
    _selectedImage = null;
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
          height: 400,
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              initialValue: _initialValue,
              child: Column(
                children: [
                  FormBuilderTextField(
                      name: "naslov",
                      validator: (value) {
                        if (value == null) {
                          return 'Naslov je obavezan';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: "Naslov")),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: "sadrzaj",
                    validator: (value) {
                      if (value == null) {
                        return 'Sadržaj je obavezan';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: "Sadržaj"),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  SizedBox(height: 8),
                  FormBuilderDateTimePicker(
                      name: "datumObjave",
                      validator: (value) {
                        if (value == null) {
                          return 'Datum objave je obavezan';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: "Datum objave")),
                  SizedBox(height: 8),
                  FormBuilderField(
                    name: 'slika',
                    validator: (value) {
                      if (_selectedImage == null &&
                          (novost == null ||
                              novost?.slika == null ||
                              novost!.slika!.isEmpty)) {
                        return 'Slika je obavezna';
                      }
                      return null;
                    },
                    builder: ((field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                            label: Text('Izaberite sliku'),
                            errorText: field.errorText),
                        child: ListTile(
                          leading: Icon(Icons.photo),
                          title: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : (novost?.slika != null &&
                                      novost!.slika!.isNotEmpty
                                  ? (novost!.slika!.startsWith('http')
                                      ? Image.network(
                                          novost!.slika!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.memory(
                                          base64Decode(novost!.slika!),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ))
                                  : Text('Nema slike')),
                          trailing: Icon(Icons.file_upload),
                          onTap: () {
                            _pickImage();
                            setState(() {});
                          },
                        ),
                      );
                    }),
                  ),
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
                                    'slika': _slikaController.text
                                  },
                                );
                              } else {
                                await _novostProvider.update(novost.novostId!, {
                                  'naslov': formData?['naslov'],
                                  'sadrzaj': formData?['sadrzaj'],
                                  'datumObjave':
                                      (formData?['datumObjave'] as DateTime?)
                                          ?.toIso8601String(),
                                  'slika': _slikaController.text
                                });
                              }
                              await _loadData();
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(novost == null ? 'Novost uspješno dodana' : 'Novost uspješno ažurirana'),
                              backgroundColor: Colors.green,)
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

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      setState(() {
        _selectedImage = imageFile;
      });

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      _slikaController.text = base64Image;
    }
  }
}
