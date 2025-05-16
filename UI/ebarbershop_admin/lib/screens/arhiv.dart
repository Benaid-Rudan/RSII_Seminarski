import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ebarbershop_admin/models/rezervacija.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart';
import 'package:provider/provider.dart';

class ArhivaListScreen extends StatefulWidget {
  const ArhivaListScreen({super.key});

  @override
  State<ArhivaListScreen> createState() => _ArhivaListScreenState();
}

class _ArhivaListScreenState extends State<ArhivaListScreen> {
  late RezervacijaProvider _rezervacijaProvider;
  SearchResult<Rezervacija>? result;
  bool _isLoading = false;
  
  TextEditingController _datumController = TextEditingController();
  TextEditingController _uslugaController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rezervacijaProvider = context.read<RezervacijaProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    String? isoDatum;
    if (_datumController.text.isNotEmpty) {
      try {
        final parsedDate = DateFormat('dd.MM.yyyy').parse(_datumController.text);
        isoDatum = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        print('Greška pri parsiranju datuma: $e');
      }
    }

    var data = await _rezervacijaProvider.get(filter: {
      "IncludeUsluga": true,
      "datumRezervacije": isoDatum,
      "usluga": _uslugaController.text
    });

    setState(() {
      result = data;
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueGrey,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400.0),
                child: child!,
              ),
              if (_datumController.text.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _datumController.clear();
                      _loadData();
                    });
                  },
                  child: Text(
                    'Očisti filter datuma', 
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _datumController.text = DateFormat('dd.MM.yyyy').format(picked);
        _loadData();
      });
    }
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
  child: InkWell(
    onTap: () => _selectDate(context),
    child: IgnorePointer(
      child: TextFormField(
        controller: _datumController,
        decoration: InputDecoration(
          labelText: "Datum obavljene usluge",
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_datumController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _datumController.clear();
                      _loadData();
                    });
                  },
                ),
              Icon(Icons.calendar_today),
            ],
          ),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.blueGrey[100],
          labelStyle: TextStyle(color: Colors.black),
        ),
      ),
    ),
  ),
),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Naziv usluge",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _uslugaController,
                onChanged: (value) => _loadData(),
              ),
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
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black),
          dataRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[900]!),
          columns: [
            DataColumn(
              label: Text(
                'Datum',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Vrijeme',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Usluga',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: result?.result.map((Rezervacija e) {
            final dateFormat = DateFormat('dd.MM.yyyy');
            final timeFormat = DateFormat('HH:mm');
            
            String formattedDate = '';
            String formattedTime = '';
            
            if (e.datumRezervacije != null) {
              formattedDate = dateFormat.format(e.datumRezervacije!);
              formattedTime = timeFormat.format(e.datumRezervacije!);
            }

            return DataRow(
              cells: [
                DataCell(Text(formattedDate, style: TextStyle(color: Colors.white))),
                DataCell(Text(formattedTime, style: TextStyle(color: Colors.white))),
                DataCell(Text(e.usluga?.naziv ?? '', style: TextStyle(color: Colors.white))),
              ],
            );
          }).toList() ?? [],
        ),
      ),
    );
  }
}