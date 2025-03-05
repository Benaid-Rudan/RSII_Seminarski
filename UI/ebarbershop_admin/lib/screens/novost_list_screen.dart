import 'package:ebarbershop_admin/models/novost.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/novost_provider.dart';
import 'package:ebarbershop_admin/screens/novost_details.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
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
    return Column(children: [
      _buildSearch(),
      _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildDataListView()
    ]);
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: "Tekst novosti"),
              controller: _tekstController,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _loadData();
            },
            child: Text("Pretraga"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NovostDetailsScreen(novost: null),
                ),
              );
            },
            child: Text("Dodaj"),
          ),
        ],
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
                  'ID',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Slika',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Tekst',
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
                    (Novost e) => DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NovostDetailsScreen(
                                novost: e,
                              ),
                            ),
                          );
                        }
                      },
                      cells: [
                        DataCell(Text(e.novostId.toString() ?? "")),
                        DataCell(
                          e.slika != null
                              ? Image.network(e.slika!, width: 50, height: 50)
                              : Icon(Icons.image, color: Colors.grey),
                        ),
                        DataCell(Text(e.sadrzaj ?? "")),
                        DataCell(
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
                                try {
                                  await _novostProvider.delete(e.novostId!);

                                  var data = await _novostProvider.get();
                                  setState(() {
                                    result = data;
                                  });
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
}
