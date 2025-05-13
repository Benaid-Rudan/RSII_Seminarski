import 'dart:io';

import 'package:ebarbershop_admin/providers/korisnik_provider.dart';
import 'package:ebarbershop_admin/providers/narudzba_provider.dart';
import 'package:ebarbershop_admin/providers/novost_provider.dart';
import 'package:ebarbershop_admin/providers/product_provider.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart';
import 'package:ebarbershop_admin/providers/termin_provider.dart';
import 'package:ebarbershop_admin/providers/usluga_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  DateTimeRange? _dateRange;
  DateTime? _startDate;
  DateTime? _endDate;
  late NarudzbaProvider _narudzbaProvider;
  late UslugaProvider _uslugaProvider;
  late RezervacijaProvider _rezervacijaProvider;
  late KorisnikProvider _korisnikProvider;
  late NovostProvider _novostProvider;
  late TerminProvider _terminProvider;
  late ProductProvider _productProvider;

  int _korisniciCount = 0;
  int _narudzbeCount = 0;
  double _narudzbeTotal = 0;
  int _novostiCount = 0;
  int _proizvodiCount = 0;
  int _rezervacijeCount = 0;
  int _terminiCount = 0;
  int _uslugeCount = 0;
  bool _isLoading = true;

  List<dynamic> _narudzbeSve = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    _uslugaProvider = context.read<UslugaProvider>();
    _rezervacijaProvider = context.read<RezervacijaProvider>();
    _korisnikProvider = context.read<KorisnikProvider>();
    _novostProvider = context.read<NovostProvider>();
    _terminProvider = context.read<TerminProvider>();
    _productProvider = context.read<ProductProvider>();

    if (_isLoading) {
      _loadData();
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final korisnici = await _korisnikProvider.get(filter: {});
      final narudzbe = await _narudzbaProvider.get(filter: {});
      final novosti = await _novostProvider.get(filter: {});
      final proizvodi = await _productProvider.get(filter: {});
      final rezervacije = await _rezervacijaProvider.get(filter: {});
      final termini = await _terminProvider.get(filter: {});
      final usluge = await _uslugaProvider.get(filter: {});

      setState(() {
        _korisniciCount = korisnici.result.length;
        _narudzbeSve = narudzbe.result;
        _narudzbeCount = narudzbe.result.length;
        _narudzbeTotal = narudzbe.result.fold<double>(0, (sum, n) => sum + (n.ukupnaCijena ?? 0));
        _novostiCount = novosti.result.length;
        _proizvodiCount = proizvodi.result.length;
        _rezervacijeCount = rezervacije.result.length;
        _terminiCount = termini.result.length;
        _uslugeCount = usluge.result.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri učitavanju podataka: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          _buildActionButtons(),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _buildDashboardGrid(),
        ],
      ),
    );
  }
  Future<void> _selectDateRange(BuildContext context) async {
  final DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    initialDateRange: _dateRange,
    helpText: 'Odaberite period',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue, 
            onPrimary: Colors.white, 
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, 
            ),
          ),
        ),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400.0,
                maxHeight: 600.0,
              ),
              child: child,
            ),
          ],
        ),
      );
    },
  );

  if (picked != null) {
    setState(() {
      _dateRange = picked;
      _startDate = picked.start;
      _endDate = picked.end;
    });
  }
}
  Widget _buildActionButtons() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _dateRange == null
              ? 'Nije odabran period'
              : 'Period: ${DateFormat('dd.MM.yyyy').format(_dateRange!.start)} - ${DateFormat('dd.MM.yyyy').format(_dateRange!.end)}',
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDateRange(context),
              tooltip: 'Odaberite period',
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.insert_drive_file),
              onPressed: _generateReport,
              tooltip: 'Generiši izvještaj',
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Osvježi podatke',
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildDashboardGrid() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard('Korisnici', _korisniciCount, Icons.people, Colors.blue),
            _buildStatCard('Narudžbe', _narudzbeCount, Icons.shopping_cart, Colors.green),
            _buildStatCard('Ukupna vrijednost narudžbi', '${_narudzbeTotal.toStringAsFixed(2)} KM',
                Icons.attach_money, Colors.orange),
            _buildStatCard('Novosti', _novostiCount, Icons.article, Colors.purple),
            _buildStatCard('Proizvodi', _proizvodiCount, Icons.shopping_bag, Colors.red),
            _buildStatCard('Rezervacije', _rezervacijeCount, Icons.calendar_today, Colors.teal),
            _buildStatCard('Termini', _terminiCount, Icons.schedule, Colors.indigo),
            _buildStatCard('Usluge', _uslugeCount, Icons.cut, Colors.blueGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
  if (_dateRange == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Molimo odaberite period za izvještaj')),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final narudzbe = await _narudzbaProvider.get(filter: {});
    final rezervacije = await _rezervacijaProvider.get(filter: {});
    final termini = await _terminProvider.get(filter: {});

    final filteredNarudzbe = narudzbe.result.where((n) {
      final datum = DateTime.tryParse(n.datum.toString());
      return datum != null && 
             datum.isAfter(_dateRange!.start.subtract(const Duration(seconds: 1))) &&
             datum.isBefore(_dateRange!.end.add(const Duration(days: 1)));
    }).toList();

    final filteredRezervacije = rezervacije.result.where((r) {
      final datum = DateTime.tryParse(r.datumRezervacije.toString());
      return datum != null && 
             datum.isAfter(_dateRange!.start.subtract(const Duration(seconds: 1))) &&
             datum.isBefore(_dateRange!.end.add(const Duration(days: 1)));
    }).toList();

    final filteredTermini = termini.result.where((t) {
      final datum = DateTime.tryParse(t.vrijeme.toString());
      return datum != null && 
             datum.isAfter(_dateRange!.start.subtract(const Duration(seconds: 1))) &&
             datum.isBefore(_dateRange!.end.add(const Duration(days: 1)));
    }).toList();

    final ukupno = filteredNarudzbe.fold<double>(0, (sum, n) => sum + (n.ukupnaCijena ?? 0));

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Izvještaj eBarbershop', 
                    style: const pw.TextStyle(fontSize: 24)),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Period: ${DateFormat('dd.MM.yyyy').format(_dateRange!.start)} - ${DateFormat('dd.MM.yyyy').format(_dateRange!.end)}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                '''
• Broj narudžbi: ${filteredNarudzbe.length}
• Ukupna cijena narudžbi: ${ukupno.toStringAsFixed(2)} KM
• Broj rezervacija: ${filteredRezervacije.length}
• Broj termina: ${filteredTermini.length}
''',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generisano: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
              ),
            ],
          );
        },
      ),
    );

    final output = await getDownloadsDirectory();
    final file = File("${output!.path}/Izvjestaj_eBarbershop_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izvještaj sačuvan u: ${file.path}')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri generiranju izvještaja: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
}