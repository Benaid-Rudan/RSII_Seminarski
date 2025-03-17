import 'package:ebarbershop_admin/models/narudzba.dart';
import 'package:ebarbershop_admin/models/product.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/narudzba_provider.dart';
import 'package:ebarbershop_admin/providers/product_provider.dart';
import 'package:ebarbershop_admin/screens/narudzba_details.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    var data = await _narudzbaProvider.get(filter: {
      "IncludeNarudzbaProizvodi": true,
      "KorisnikId": _korisnikIdController.text,
      "NarudzbaId": _narudzbaIdController.text
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
                  labelText: "Kupac Id",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _korisnikIdController,
                onChanged: (value) {
                  _loadData();
                },
              ),
            ),
            SizedBox(width: 18),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Narudzba Id",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _narudzbaIdController,
                onChanged: (value) {
                  _loadData();
                },
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _showNarudzbaDialog(context);
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
              label: Expanded(
                child: Text(
                  'Narudzba Id',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Kupac Id',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Proizvod',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Cijena',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Datum i vrijeme',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const DataColumn(
              label: Expanded(
                child: Text(
                  'Akcije',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          rows: result?.result.asMap().entries.map((entry) {
                int index = entry.key;
                Narudzba e = entry.value;

                return DataRow(
                  color: MaterialStateColor.resolveWith(
                    (states) =>
                        index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!,
                  ),
                  cells: [
                    DataCell(Text("${e.narudzbaId ?? ''}",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text("${e.korisnikId ?? ''}",
                        style: TextStyle(color: Colors.white))),
                    DataCell(
                      Text(
                          e.narudzbaProizvodis
                                  ?.map((np) => np.proizvod?.naziv)
                                  .join(', ') ??
                              "",
                          style: TextStyle(color: Colors.white)),
                    ),
                    DataCell(Text(
                        e.narudzbaProizvodis
                                ?.map((np) =>
                                    np.proizvod?.cijena?.toStringAsFixed(2))
                                .join(', ') ??
                            "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(
                        e.datum != null ? e.datum!.toIso8601String() : "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showNarudzbaDialog(context, narudzba: e);
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

  Future<void> _showNarudzbaDialog(BuildContext context,
      {Narudzba? narudzba}) async {
    final _formKey = GlobalKey<FormBuilderState>();
    Map<String, dynamic> _initalValue = {
      'datum': narudzba?.datum != null
          ? DateTime.parse(narudzba!.datum!.toString())
          : null,
      'proizvodId': narudzba?.narudzbaProizvodis?.isNotEmpty == true
          ? narudzba?.narudzbaProizvodis?.first.proizvodId.toString() ?? ''
          : '',
      'kupacId': narudzba?.korisnikId?.toString(),
      'kolicina': narudzba?.narudzbaProizvodis?.isNotEmpty == true
          ? narudzba?.narudzbaProizvodis?.first.kolicina.toString() ?? ''
          : '',
      'cijena': narudzba?.narudzbaProizvodis?.isNotEmpty == true
          ? narudzba?.narudzbaProizvodis?.first.proizvod?.cijena.toString() ??
              ''
          : '',
      'ukupnaCijena': null,
    };

    final productProvider = context.read<ProductProvider>();
    final narudzbaProvider = context.read<NarudzbaProvider>();

    SearchResult<Product>? productResult = await productProvider.get();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(narudzba != null ? "Uredi narudžbu" : "Dodaj narudžbu"),
          content: Container(
            width: 400,
            height: 300,
            child: SingleChildScrollView(
              child: FormBuilder(
                key: _formKey,
                initialValue: _initalValue,
                child: Column(
                  children: [
                    FormBuilderDropdown<String>(
                      name: 'proizvodId',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Proizvod je obavezan';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Proizvod',
                        hintText: 'Odaberite proizvod',
                      ),
                      items: productResult?.result
                              .map((item) => DropdownMenuItem(
                                    value: item.proizvodId?.toString(),
                                    child: Text(item.naziv ?? ""),
                                  ))
                              .toList() ??
                          [],
                      onChanged: (value) {
                        var selectedProduct = productResult?.result.firstWhere(
                          (p) => p.proizvodId.toString() == value,
                          orElse: () => Product(0, '', '', 0.0, '', 0, 0),
                        );

                        double cijena = selectedProduct?.cijena ?? 0;
                        _formKey.currentState!.fields['cijena']
                            ?.didChange(cijena.toString());

                        String? kolicina =
                            _formKey.currentState!.fields['kolicina']?.value;
                        _updateUkupnaCijena(_formKey, cijena, kolicina);
                      },
                    ),
                    SizedBox(height: 8),
                    FormBuilderTextField(
                      name: "kupacId",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kupac ID je obavezan';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Kupac ID"),
                    ),
                    SizedBox(height: 8),
                    FormBuilderTextField(
                      name: "cijena",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Cijena je obavezna';
                        }
                        return null;
                      },
                      enabled: false,
                      decoration: InputDecoration(labelText: "Cijena"),
                    ),
                    SizedBox(height: 8),
                    FormBuilderTextField(
                      name: "kolicina",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Količina"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Količina je obavezna';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        String? proizvodId =
                            _formKey.currentState!.fields['proizvodId']?.value;
                        var selectedProduct = productResult?.result.firstWhere(
                            (p) => p?.proizvodId.toString() == proizvodId,
                            orElse: () => Product(0, '', '', 0.0, '', 0, 0));

                        double cijena = selectedProduct?.cijena ?? 0;
                        _updateUkupnaCijena(_formKey, cijena, value);
                      },
                    ),
                    SizedBox(height: 8),
                    FormBuilderDateTimePicker(
                      name: "datum",
                      validator: (value) {
                        if (value == null) {
                          return 'Datum je obavezan';
                        }

                        return null;
                      },
                      initialValue: narudzba?.datum != null
                          ? DateTime.parse(narudzba!.datum!.toString())
                          : DateTime.now(),
                      decoration: InputDecoration(labelText: "Datum"),
                      inputType: InputType.both,
                      format: DateFormat("yyyy-MM-dd HH:mm"),
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
                _formKey.currentState?.saveAndValidate();
                final formData =
                    Map<String, dynamic>.from(_formKey.currentState!.value);

                String? proizvodId = formData['proizvodId'];
                var selectedProduct = productResult?.result.firstWhere(
                  (p) => p.proizvodId.toString() == proizvodId,
                  orElse: () => Product(0, '', '', 0.0, '', 0, 0),
                );

                double cijena = selectedProduct?.cijena ?? 0;
                int kolicina = int.tryParse(formData['kolicina'] ?? "0") ?? 0;
                double ukupnaCijena = cijena * kolicina;

                List<Map<String, dynamic>> listaProizvoda = [
                  {
                    "proizvodID": int.parse(formData['proizvodId']),
                    "kolicina": kolicina,
                    "cijena": cijena,
                  }
                ];

                Map<String, dynamic> requestData = {
                  "datum": (formData['datum'] as DateTime).toIso8601String(),
                  "ukupnaCijena": ukupnaCijena,
                  "korisnikId": int.parse(formData['kupacId']),
                  "listaProizvoda": listaProizvoda,
                };

                if (narudzba == null) {
                  await narudzbaProvider.insert(requestData);
                } else {
                  if (narudzba.narudzbaId != null) {
                    await narudzbaProvider.update(
                      narudzba.narudzbaId!,
                      requestData,
                    );
                  }
                }

                Navigator.pop(context);
                _loadData();
              },
              child: Text("Sačuvaj"),
            ),
          ],
        );
      },
    );
  }

  void _updateUkupnaCijena(
      GlobalKey<FormBuilderState> formKey, double cijena, String? kolicina) {
    int kol = int.tryParse(kolicina ?? "0") ?? 0;
    double ukupna = cijena * kol;

    formKey.currentState!.fields['cijena']?.didChange(cijena.toString());
    formKey.currentState!.fields['ukupnaCijena']?.didChange(ukupna.toString());
  }
}
