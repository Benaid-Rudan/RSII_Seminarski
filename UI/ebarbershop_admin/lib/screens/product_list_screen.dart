import 'package:ebarbershop_admin/models/product.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/product_provider.dart';
import 'package:ebarbershop_admin/screens/product_details.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductProvider _productProvider;
  SearchResult<Product>? result;

  TextEditingController _nazivController = new TextEditingController();
  TextEditingController _opisController =
      new TextEditingController(); //drugi filter + dodati u ProizvodSearchObject

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _productProvider = context.read<ProductProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title_widget: Text("Product list"),
      child: Container(
        child: Column(children: [_buildSearch(), _buildDataListView()]),
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
                  decoration: InputDecoration(labelText: "Naziv"),
                  controller: _nazivController)),
          SizedBox(
            width: 18,
          ),
          Expanded(
              child: TextField(
                  decoration: InputDecoration(labelText: "Opis"),
                  controller: _opisController)),
          ElevatedButton(
              onPressed: () async {
                // print("Login proceed");
                // Navigator.of(context).pop();
                // Navigator.of(context).push(MaterialPageRoute(
                //   builder: (context) => const ProductDetailsScreen(),
                // ));
                var data = await _productProvider.get(filter: {
                  'naziv': _nazivController.text,
                  'opis': _opisController.text
                });

                setState(() {
                  result = data;
                });

                // print("data: ${data.result[0].naziv}");
              },
              child: Text("Pretraga")),
          ElevatedButton(
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(
                      product: null,
                    ),
                  ),
                );
              },
              child: Text("Dodaj"))
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
        child: SingleChildScrollView(
            child: DataTable(
                columns: [
          const DataColumn(
            label: const Expanded(
              child: const Text(
                'ID',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
          const DataColumn(
            label: const Expanded(
              child: const Text(
                'Naziv',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
          const DataColumn(
            label: const Expanded(
              child: const Text(
                'Opis',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
          const DataColumn(
            label: const Expanded(
              child: const Text(
                'Cijena',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
          const DataColumn(
            label: const Expanded(
              child: const Text(
                'Slika',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
                rows: result?.result
                        .map((Product e) => DataRow(
                                onSelectChanged: (selected) => {
                                      if (selected == true)
                                        // {print('Selected: ${e.proizvodId}')}
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailsScreen(
                                            product: e,
                                          ),
                                        ))
                                    },
                                cells: [
                                  DataCell(Text(e.proizvodId.toString() ?? "")),
                                  DataCell(Text(e.naziv.toString() ?? "")),
                                  DataCell(Text(e.opis.toString() ?? "")),
                                  DataCell(Text(formatNumber(e.cijena))),
                                  DataCell(Container(
                                    width: 100,
                                    height: 100,
                                    child: (e.slika != "string")
                                        ? imageFromBase64String(e.slika!)
                                        : Icon(Icons.image),
                                  )),
                                ]))
                        .toList() ??
                    [])));
  }
}
