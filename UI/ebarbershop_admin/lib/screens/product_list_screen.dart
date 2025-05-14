import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ebarbershop_admin/models/product.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/vrsta_proizvoda.dart';
import 'package:ebarbershop_admin/providers/product_provider.dart';
import 'package:ebarbershop_admin/providers/vrsta_proizvoda.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductProvider _productProvider;
  late VrstaProizvodaProvider _vrstaProizvodaProvider;
  SearchResult<Product>? result;
  SearchResult<VrstaProizvoda>? vrstaProizvodaResult;
  bool _isLoading = false;
  TextEditingController _nazivController = TextEditingController();
  TextEditingController _opisController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  TextEditingController _slikaController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = context.read<ProductProvider>();
    _vrstaProizvodaProvider = context.read<VrstaProizvodaProvider>();
    _fetchData();
  }

  Future<void> _fetchData({String? naziv, String? opis}) async {
    setState(() => _isLoading = true);
    var productData = await _productProvider
        .get(filter: {'naziv': naziv ?? '', 'opis': opis ?? ''});
    var vrstaProizvodaData = await _vrstaProizvodaProvider.get();
    setState(() {
      result = productData;
      vrstaProizvodaResult = vrstaProizvodaData;
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
                  labelText: "Naziv",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _nazivController,
                onChanged: (value) {
                  _fetchData(naziv: value, opis: _opisController.text);
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Opis",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _opisController,
                onChanged: (value) {
                  _fetchData(naziv: _nazivController.text, opis: value);
                },
              ),
            ),
            SizedBox(width: 16),
            if(Authorization.isAdmin())
                ElevatedButton(
                  onPressed: () => _showProductDialog(),
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
                label: Text('Naziv',
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
            DataColumn(
                label: Text('Slika',
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
                Product e = entry.value;

                return DataRow(
                  color: MaterialStateColor.resolveWith(
                    (states) =>
                        index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!,
                  ),
                  cells: [
                    DataCell(Text(e.proizvodId.toString() ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(e.naziv ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(e.opis ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(formatNumber(e.cijena),
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
                    if (Authorization.isAdmin()) 
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showProductDialog(product: e),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(e),
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

  Future<void> _deleteProduct(Product product) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Potvrdi brisanje"),
        content: Text("Da li ste sigurni da želite obrisati ovaj proizvod?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Ne"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Da"),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _productProvider.delete(product.proizvodId!);
        await _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Proizvod uspješno obrisan'),
                                    backgroundColor: Colors.red,
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
  }

  void _showProductDialog({Product? product}) {
    _selectedImage = null;
    
     if (product != null && product.slika != null && product.slika!.isNotEmpty) {
      _slikaController.text = product.slika!;
    } else {
      _slikaController.text = "";
    }

    final initialValues = {
      'naziv': product?.naziv ?? "",
      'opis': product?.opis ?? "",
      'cijena': product?.cijena?.toString() ?? "",
      'slika': product?.slika ?? "",
      'zalihe': product?.zalihe?.toString() ?? "",
      'vrstaProizvodaId': product?.vrstaProizvodaId?.toString() ?? "",
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? "Dodaj proizvod" : "Uredi proizvod"),
        content: Container(
          width: 400,
          height: 450,
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              initialValue: initialValues,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'naziv',
                    decoration: InputDecoration(labelText: "Naziv"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Naziv je obavezan';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'opis',
                    decoration: InputDecoration(labelText: "Opis"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Opis je obavezan';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                  name: 'cijena',
                  decoration: InputDecoration(labelText: "Cijena"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  SizedBox(height: 8),
                  FormBuilderField(
                    name: 'slika',
                    validator: (value) {
                      if (_selectedImage == null &&
                          (product == null ||
                              product?.slika == null ||
                              product!.slika!.isEmpty)) {
                        return 'Slika je obavezna';
                      }
                      return null;
                    },
                    builder: ((field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          label: Text('Izaberite sliku'),
                          errorText:
                              field.errorText,
                        ),
                        child: ListTile(
                          leading: Icon(Icons.photo),
                          title: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : (product?.slika != null &&
                                      product!.slika!.isNotEmpty
                                  ? (product!.slika!.startsWith('http')
                                      ? Image.network(
                                          product!.slika!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.memory(
                                          base64Decode(product!.slika!),
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
                  SizedBox(height: 8),
                  FormBuilderTextField(
                  name: 'zalihe',
                  decoration: InputDecoration(labelText: "Zalihe"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Zalihe su obavezne';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Unesite cijeli broj (npr. 5)';
                    }
                    return null;
                  },
                ),
                  SizedBox(height: 8),
                  FormBuilderDropdown<String>(
                    name: 'vrstaProizvodaId',
                    decoration: InputDecoration(labelText: "Vrsta proizvoda"),
                    items: vrstaProizvodaResult?.result
                            .map((item) => DropdownMenuItem(
                                  value: item.vrstaProizvodaId?.toString(),
                                  child: Text(item.naziv ?? ""),
                                ))
                            .toList() ??
                        [],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vrsta proizvoda je obavezna';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Odustani"),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            final formData = _formKey.currentState?.value;

                            // Check if at least one parameter is entred
                            if (formData?['naziv'].isEmpty &&
                                formData?['opis'].isEmpty &&
                                formData?['cijena'].isEmpty &&
                                formData?['slika'].isEmpty &&
                                formData?['zalihe'].isEmpty &&
                                formData?['vrstaProizvodaId'].isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Greška"),
                                  content: Text(
                                      "Svi parametri su obavezni za unos."),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            try {
                              if (product == null) {
                                await _productProvider.insert({
                                  'naziv': formData?['naziv'],
                                  'opis': formData?['opis'],
                                  'cijena': double.tryParse(
                                      formData?['cijena'] ?? "0"),
                                  'slika': _slikaController.text,
                                  'zalihe':
                                      int.tryParse(formData?['zalihe'] ?? "0"),
                                  'vrstaProizvodaId':
                                      formData?['vrstaProizvodaId'],
                                });
                              } else {
                                await _productProvider.update(
                                  product.proizvodId!,
                                  {
                                    'naziv': formData?['naziv'],
                                    'opis': formData?['opis'],
                                    'cijena': double.tryParse(
                                        formData?['cijena'] ?? "0"),
                                    'slika': _slikaController.text,
                                    'zalihe': int.tryParse(
                                        formData?['zalihe'] ?? "0"),
                                    'vrstaProizvodaId':
                                        formData?['vrstaProizvodaId'],
                                  },
                                );
                              }

                              await _fetchData();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(product == null ? 'Proizvod uspješno dodan' : 'Proizvod uspješno ažuriran'),
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
