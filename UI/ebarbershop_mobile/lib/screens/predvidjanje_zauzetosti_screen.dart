import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/predvidjanje_zauzetosti.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';
import 'package:ebarbershop_mobile/providers/predvidjanje_zauzetosti_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PredvidjanjeZauzetostiScreen extends StatefulWidget {
  final Usluga usluga;
  final Korisnik frizer;
  final DateTime selectedDate;
  const PredvidjanjeZauzetostiScreen({
    Key? key,
    required this.usluga,
    required this.frizer,
    required this.selectedDate
      }) : super(key: key);

  @override
  State<PredvidjanjeZauzetostiScreen> createState() =>
      _PredvidjanjeZauzetostiScreenState();
}

class _PredvidjanjeZauzetostiScreenState
    extends State<PredvidjanjeZauzetostiScreen> {
  late PredvidjanjeZauzetostiProvider _provider;
  PredvidjanjeZauzetosti? _rezultat;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _provider = context.read<PredvidjanjeZauzetostiProvider>();
    _predvidiZauzetost();
  }

  Future<void> _predvidiZauzetost() async {
    setState(() => _isLoading = true);

    try {
      final prediction = await _provider.predvidiZauzetostZaFrizera(
        widget.frizer.korisnikId!,
        widget.selectedDate,
        
      );

      if (mounted) {
        setState(() {
          _rezultat = prediction;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri dohvaćanju zauzetosti: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predviđanje zauzetosti'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.blueGrey[900],
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _rezultat == null
              ? Center(child: Text("Nema dostupnih podataka."))
              : _buildResult(),
    );
  }

Widget _buildResult() {
  if (_rezultat == null || _rezultat!.zauzetostPoSatima == null || _rezultat!.zauzetostPoSatima!.isEmpty) {
    return Center(
      child: Text(
        "Nema dostupnih podataka o zauzetosti",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(20),
    child: Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frizer: ${widget.frizer.ime} ${widget.frizer.prezime}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Datum: ${DateFormat('dd.MM.yyyy').format(widget.selectedDate)}',
            style: TextStyle(
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Zauzetost: ${(_rezultat!.ukupnaZauzetost! * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 24,
              color: _rezultat!.ukupnaZauzetost! > 0.7
                  ? Colors.red
                  : _rezultat!.ukupnaZauzetost! > 0.4
                      ? Colors.orange
                      : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Zauzetost po satima:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          // If zauzetostPoSatima is a Map<String, double>
          Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _rezultat!.zauzetostPoSatima!
              .map((z) => Chip(
                    label: Text(
                      '${z.sat}: ${(z.vrijednost! * 100).toStringAsFixed(0)}%',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: z.vrijednost! > 0.7
                        ? Colors.red[800]
                        : z.vrijednost! > 0.4
                            ? Colors.orange[800]
                            : Colors.green[800],
                  ))
              .toList(),
        )

         
        ],
      ),
    ),
  );
}
}