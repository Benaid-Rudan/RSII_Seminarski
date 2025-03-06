import 'package:ebarbershop_admin/models/product.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/vrsta_proizvoda.dart';
import 'package:ebarbershop_admin/providers/product_provider.dart';
import 'package:ebarbershop_admin/providers/vrsta_proizvoda.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:flutter/material.dart';
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

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = context.read<ProductProvider>();
    _vrstaProizvodaProvider = context.read<VrstaProizvodaProvider>();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    var productData = await _productProvider.get();
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
                ),
                controller: _nazivController,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Opis",
                  border: OutlineInputBorder(),
                ),
                controller: _opisController,
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                var data = await _productProvider.get(filter: {
                  'naziv': _nazivController.text,
                  'opis': _opisController.text
                });
                setState(() {
                  result = data;
                  _isLoading = false;
                });
              },
              child: Text("Pretraga"),
            ),
            SizedBox(width: 16),
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
          columns: [
            DataColumn(
                label:
                    Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Naziv',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Opis',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Cijena',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Slika',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Akcije',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: result?.result
                  .map((Product e) => DataRow(
                        cells: [
                          DataCell(Text(e.proizvodId.toString() ?? "")),
                          DataCell(Text(e.naziv ?? "")),
                          DataCell(Text(e.opis ?? "")),
                          DataCell(Text(formatNumber(e.cijena))),
                          DataCell(
                            Container(
                              width: 100,
                              height: 100,
                              child: (e.slika != "string")
                                  ? Image.network(e.slika!)
                                  : Icon(Icons.image),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () =>
                                      _showProductDialog(product: e),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProduct(e),
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
          width: 400, // Fiksna širina dijaloga
          height: 380, // Fiksna visina dijaloga
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
                  ),
                  SizedBox(height: 8), // Smanjen razmak
                  FormBuilderTextField(
                    name: 'opis',
                    decoration: InputDecoration(labelText: "Opis"),
                  ),
                  SizedBox(height: 8), // Smanjen razmak
                  FormBuilderTextField(
                    name: 'cijena',
                    decoration: InputDecoration(labelText: "Cijena"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8), // Smanjen razmak
                  FormBuilderTextField(
                    name: 'slika',
                    decoration: InputDecoration(labelText: "Slika"),
                  ),
                  SizedBox(height: 8), // Smanjen razmak
                  FormBuilderTextField(
                    name: 'zalihe',
                    decoration: InputDecoration(labelText: "Zalihe"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8), // Smanjen razmak
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
                  ),
                  SizedBox(height: 12), // Smanjen razmak prije dugmadi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Odustani"),
                      ),
                      SizedBox(width: 8), // Smanjen razmak između dugmadi
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            final formData = _formKey.currentState?.value;

                            try {
                              if (product == null) {
                                await _productProvider.insert({
                                  'naziv': formData?['naziv'],
                                  'opis': formData?['opis'],
                                  'cijena': double.tryParse(
                                      formData?['cijena'] ?? "0"),
                                  'slika': formData?['slika'],
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
                                    'slika': formData?['slika'],
                                    'zalihe': int.tryParse(
                                        formData?['zalihe'] ?? "0"),
                                    'vrstaProizvodaId':
                                        formData?['vrstaProizvodaId'],
                                  },
                                );
                              }

                              await _fetchData();
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
