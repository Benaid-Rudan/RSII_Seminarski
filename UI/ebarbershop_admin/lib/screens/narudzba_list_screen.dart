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
                  'Ukupna cijena',
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
                        e.ukupnaCijena?.toStringAsFixed(2) ?? "0.00",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(
                        e.datum != null 
                            ? DateFormat('dd.MM.yyyy HH:mm').format(e.datum!) 
                            : "",
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
                                   ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Narudžba uspješno obrisana'),
                                    backgroundColor: Colors.red,
                                  )
                                );
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
    
    // Lista za skladištenje odabranih proizvoda i njihovih količina
    List<Map<String, dynamic>> selectedProducts = [];
    double ukupnaCijena = 0.0;
    
    // Ako uređujemo, popunimo već odabrane proizvode
    if (narudzba != null && narudzba.narudzbaProizvodis != null) {
      for (var np in narudzba.narudzbaProizvodis!) {
        if (np.proizvodId != null && np.kolicina != null && np.proizvod != null) {
          selectedProducts.add({
            'proizvodId': np.proizvodId,
            'kolicina': np.kolicina,
            'naziv': np.proizvod!.naziv,
            'cijena': np.proizvod!.cijena,
            'ukupnaCijenaStavke': np.proizvod!.cijena! * np.kolicina!
          });
          ukupnaCijena += (np.proizvod!.cijena! * np.kolicina!);
        }
      }
    }
    
    Map<String, dynamic> _initalValue = {
      'datum': narudzba?.datum ?? DateTime.now(),
      'kupacId': narudzba?.korisnikId?.toString() ?? '',
      'ukupnaCijena': ukupnaCijena.toStringAsFixed(2),
    };

    final productProvider = context.read<ProductProvider>();
    final narudzbaProvider = context.read<NarudzbaProvider>();

    SearchResult<Product>? productResult = await productProvider.get();
    Product? selectedProduct;
    int selectedQuantity = 1;

    // Controller za prikaz trenutnog ukupnog iznosa
    TextEditingController _ukupnaCijenaController = TextEditingController();
    _ukupnaCijenaController.text = ukupnaCijena.toStringAsFixed(2);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Funkcija za ažuriranje ukupne cijene
            void updateUkupnaCijena() {
              ukupnaCijena = 0.0;
              for (var product in selectedProducts) {
                ukupnaCijena += product['ukupnaCijenaStavke'] as double;
              }
              _ukupnaCijenaController.text = ukupnaCijena.toStringAsFixed(2);
            }

            // Funkcija za dodavanje proizvoda u listu
            void addProductToList() {
              if (selectedProduct != null && selectedQuantity > 0) {
                // Provjeri da li proizvod već postoji u listi
                int existingIndex = selectedProducts.indexWhere(
                    (p) => p['proizvodId'] == selectedProduct!.proizvodId);

                if (existingIndex >= 0) {
                  // Ako postoji, samo ažuriraj količinu
                  setDialogState(() {
                    selectedProducts[existingIndex]['kolicina'] += selectedQuantity;
                    selectedProducts[existingIndex]['ukupnaCijenaStavke'] = 
                        selectedProducts[existingIndex]['cijena'] * selectedProducts[existingIndex]['kolicina'];
                    updateUkupnaCijena();
                  });
                } else {
                  // Ako ne postoji, dodaj novi proizvod
                  setDialogState(() {
                    selectedProducts.add({
                      'proizvodId': selectedProduct!.proizvodId,
                      'naziv': selectedProduct!.naziv,
                      'kolicina': selectedQuantity,
                      'cijena': selectedProduct!.cijena,
                      'ukupnaCijenaStavke': selectedProduct!.cijena! * selectedQuantity
                    });
                    updateUkupnaCijena();
                  });
                }
                
                // Resetiraj odabir za sljedeći unos
                selectedProduct = null;
                selectedQuantity = 1;
              }
            }

            return AlertDialog(
              title: Text(narudzba != null ? "Uredi narudžbu" : "Dodaj narudžbu"),
              content: Container(
                width: 600,
                height: 500,
                child: SingleChildScrollView(
                  child: FormBuilder(
                    key: _formKey,
                    initialValue: _initalValue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        SizedBox(height: 16),
                        FormBuilderDateTimePicker(
                          name: "datum",
                          validator: (value) {
                            if (value == null) {
                              return 'Datum je obavezan';
                            }
                            return null;
                          },
                          initialValue: narudzba?.datum ?? DateTime.now(),
                          decoration: InputDecoration(labelText: "Datum"),
                          inputType: InputType.both,
                          format: DateFormat("yyyy-MM-dd HH:mm"),
                        ),
                        SizedBox(height: 16),
                        
                        // Sekcija za dodavanje proizvoda
                        Text("Dodaj proizvode:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        
                        // Redak za odabir proizvoda i količine
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButton<Product>(
                                hint: Text("Odaberite proizvod"),
                                isExpanded: true,
                                value: selectedProduct,
                                items: productResult?.result.map((Product product) {
                                  return DropdownMenuItem<Product>(
                                    value: product,
                                    child: Text("${product.naziv} (${product.cijena?.toStringAsFixed(2)} KM)"),
                                  );
                                }).toList(),
                                onChanged: (Product? value) {
                                  setDialogState(() {
                                    selectedProduct = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                decoration: InputDecoration(labelText: "Količina"),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  int? parsed = int.tryParse(value);
                                  if (parsed != null && parsed > 0) {
                                    setDialogState(() {
                                      selectedQuantity = parsed;
                                    });
                                  }
                                },
                                controller: TextEditingController(text: selectedQuantity.toString()),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.green),
                              onPressed: addProductToList,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        
                        // Lista odabranih proizvoda
                        if (selectedProducts.isNotEmpty)
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: selectedProducts.length,
                              itemBuilder: (context, index) {
                                final product = selectedProducts[index];
                                return ListTile(
                                  title: Text("${product['naziv']}"),
                                  subtitle: Text("${product['kolicina']} x ${product['cijena']?.toStringAsFixed(2)} KM = ${product['ukupnaCijenaStavke']?.toStringAsFixed(2)} KM"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          // Prikazivanje dijaloga za uređivanje količine
                                          TextEditingController editController = TextEditingController(
                                              text: product['kolicina'].toString());
                                          
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text("Promijeni količinu"),
                                              content: TextField(
                                                controller: editController,
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(labelText: "Nova količina"),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text("Odustani"),
                                                  onPressed: () => Navigator.of(ctx).pop(),
                                                ),
                                                TextButton(
                                                  child: Text("Sačuvaj"),
                                                  onPressed: () {
                                                    int? newQuantity = int.tryParse(editController.text);
                                                    if (newQuantity != null && newQuantity > 0) {
                                                      setDialogState(() {
                                                        selectedProducts[index]['kolicina'] = newQuantity;
                                                        selectedProducts[index]['ukupnaCijenaStavke'] = 
                                                            product['cijena'] * newQuantity;
                                                        updateUkupnaCijena();
                                                      });
                                                    }
                                                    Navigator.of(ctx).pop();
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setDialogState(() {
                                            selectedProducts.removeAt(index);
                                            updateUkupnaCijena();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        SizedBox(height: 16),
                        
                        // Ukupna cijena
                        TextField(
                          controller: _ukupnaCijenaController,
                          decoration: InputDecoration(
                            labelText: "Ukupna cijena",
                            prefixText: "KM ",
                          ),
                          enabled: false,
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
                      if (selectedProducts.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Dodajte barem jedan proizvod'))
                        );
                        return;
                      }
                      
                      final formData = Map<String, dynamic>.from(_formKey.currentState!.value);

                      // Pripremamo listu proizvoda za API
                      List<Map<String, dynamic>> listaProizvoda = selectedProducts.map((p) => {
                        "proizvodID": p['proizvodId'],
                        "kolicina": p['kolicina'],
                      }).toList();

                      Map<String, dynamic> requestData = {
                        "datum": (formData['datum'] as DateTime).toIso8601String(),
                        "ukupnaCijena": ukupnaCijena,
                        "korisnikId": int.parse(formData['kupacId']),
                        "listaProizvoda": listaProizvoda,
                      };

                      try {
                        if (narudzba == null) {
                          await narudzbaProvider.insert(requestData);
                        } else if (narudzba.narudzbaId != null) {
                          await narudzbaProvider.update(
                            narudzba.narudzbaId!,
                            requestData,
                          );
                        }
                        Navigator.pop(context);
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(narudzba == null ? 'Narudžba uspješno dodana' : 'Narudžba uspješno ažurirana'),
                            backgroundColor: Colors.green,
                          )
                        );
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
                  child: Text("Sačuvaj"),
                ),
              ],
            );
          }
        );
      },
    );
  }
}