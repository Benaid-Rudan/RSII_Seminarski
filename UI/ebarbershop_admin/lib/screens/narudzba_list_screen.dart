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
                ),
                controller: _korisnikIdController,
              ),
            ),
            SizedBox(width: 18),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Narudzba Id",
                  border: OutlineInputBorder(),
                ),
                controller: _narudzbaIdController,
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
        child: DataTable(
          columns: [
            DataColumn(
              label: Expanded(
                child: Text(
                  'Narudzba Id',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Kupac Id',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Proizvod',
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
            DataColumn(
              label: Expanded(
                child: Text(
                  'Datum i vrijeme',
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
                    (Narudzba e) => DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          _showNarudzbaDialog(context, narudzba: e);
                        }
                      },
                      cells: [
                        DataCell(Text("${e.narudzbaId ?? ''}")),
                        DataCell(Text("${e.korisnikId ?? ''}")),
                        DataCell(
                          Text(
                            e.narudzbaProizvodis
                                    ?.map((np) => np.proizvod?.naziv)
                                    .join(', ') ??
                                "",
                          ),
                        ),
                        DataCell(Text(
                          e.narudzbaProizvodis
                                  ?.map((np) =>
                                      np.proizvod?.cijena?.toStringAsFixed(2))
                                  .join(', ') ??
                              "",
                        )),
                        DataCell(Text(
                            e.datum != null ? e.datum!.toIso8601String() : "")),
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
                                    builder: (BuildContext context) =>
                                        AlertDialog(
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
                                      await _narudzbaProvider
                                          .delete(e.narudzbaId!);
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
                    ),
                  )
                  .toList() ??
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
          ? narudzba?.narudzbaProizvodis?.first.proizvodId.toString()
          : null,
      'kupacId': narudzba?.korisnikId?.toString(),
      'kolicina': narudzba?.narudzbaProizvodis?.isNotEmpty == true
          ? narudzba?.narudzbaProizvodis?.first.kolicina.toString()
          : null,
      'cijena': narudzba?.narudzbaProizvodis?.isNotEmpty == true
          ? narudzba?.narudzbaProizvodis?.first.proizvod?.cijena.toString()
          : null,
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
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Kupac ID"),
                    ),
                    SizedBox(height: 8),
                    FormBuilderTextField(
                      name: "cijena",
                      enabled: false,
                      decoration: InputDecoration(labelText: "Cijena"),
                    ),
                    SizedBox(height: 8),
                    FormBuilderTextField(
                      name: "kolicina",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Količina"),
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

                // Dohvati odabrani proizvod
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
                    "cijena": cijena, // Postavite cijenu proizvoda
                  }
                ];

                Map<String, dynamic> requestData = {
                  "datum": (formData['datum'] as DateTime).toIso8601String(),
                  "ukupnaCijena": ukupnaCijena, // Postavite ukupnu cijenu
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
                _loadData(); // Osvežite listu narudžbi nakon dodavanja/izmjene
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
