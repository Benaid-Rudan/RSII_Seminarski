import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ebarbershop_mobile/models/preporuka_termina.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';
import 'package:ebarbershop_mobile/providers/preporuka_termina_provider.dart';
import 'package:ebarbershop_mobile/providers/rezervacija_provider.dart';
import 'package:ebarbershop_mobile/providers/termin_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';

class PreporukeTerminaScreen extends StatefulWidget {
  final Usluga usluga;
  
  const PreporukeTerminaScreen({Key? key, required this.usluga}) : super(key: key);

  @override
  _PreporukeTerminaScreenState createState() => _PreporukeTerminaScreenState();
}

class _PreporukeTerminaScreenState extends State<PreporukeTerminaScreen> {
  late PreporukaTerminaProvider _preporukaProvider;
  late RezervacijaProvider _rezervacijaProvider;
  late TerminProvider _terminProvider;
  List<PreporukaTermina> _preporuke = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _preporukaProvider = context.read<PreporukaTerminaProvider>();
    _rezervacijaProvider = context.read<RezervacijaProvider>();
    _terminProvider = context.read<TerminProvider>();
    _loadPreporuke();
  }

  Future<void> _loadPreporuke() async {
    try {
      setState(() => _isLoading = true);
      
      final currentUserId = Authorization.userId;
      if (currentUserId == null) {
        throw Exception("User not logged in");
      }

      final preporuke = await _preporukaProvider.generirajPreporuke(
        currentUserId, 
        widget.usluga.uslugaId!
      );

      if (mounted) {
        setState(() {
          _preporuke = preporuke;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri učitavanju preporuka: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _prihvatiPreporuku(PreporukaTermina preporuka) async {
    try {
      
      // Prvo prihvatimo preporuku
      await _preporukaProvider.prihvatiPreporuku(preporuka.preporukaId!);

      // Kreiraj rezervaciju
      final createdReservation = await _rezervacijaProvider.createReservation(
        datumRezervacije: DateTime.now(),
        korisnikId: preporuka.korisnikId!,
        klijentId: preporuka.klijentId!,
        uslugaId: preporuka.uslugaId!,
      );

      // Kreiraj termin
      await _terminProvider.insert({
        "vrijeme": preporuka.preporuceniTermin!.toIso8601String(),
        "rezervacijaId": createdReservation.rezervacijaId,
        "korisnikID": preporuka.korisnikId,
        "klijentId": preporuka.klijentId,
        "isBooked": true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preporuka prihvaćena i rezervacija kreirana!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Vrati se na početni ekran
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri prihvatanju preporuke: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preporučeni termini'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.blueGrey,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildServiceInfo(),
        Divider(color: Colors.grey.shade700, thickness: 1),
        Expanded(
          child: _preporuke.isEmpty
              ? _buildEmptyState()
              : _buildPreporukeList(),
        ),
      ],
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.cut,
              size: 30,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.usluga.naziv ?? 'Nepoznata usluga',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cijena: ${widget.usluga.cijena?.toStringAsFixed(2)} BAM',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Nema dostupnih preporuka',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pokušajte ponovo kasnije ili odaberite termin ručno',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreporukeList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _preporuke.length,
      itemBuilder: (context, index) => _buildPreporukaCard(_preporuke[index]),
    );
  }

  Widget _buildPreporukaCard(PreporukaTermina preporuka) {
    final DateTime date = preporuka.preporuceniTermin!;
    final String formattedDate = DateFormat('dd.MM.yyyy').format(date);
    final String formattedTime = DateFormat('HH:mm').format(date);
    final String weekday = _getWeekdayName(date.weekday);
    
    // Confidence score color
    Color scoreColor = preporuka.skorPovjerenja! > 0.8 
        ? Colors.green 
        : preporuka.skorPovjerenja! > 0.6 
            ? Colors.orange 
            : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$weekday, $formattedDate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor),
                  ),
                  child: Text(
                    '${(preporuka.skorPovjerenja! * 100).round()}%',
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            if (preporuka.korisnik != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: preporuka.korisnik!.slika != null && preporuka.korisnik!.slika!.isNotEmpty
                        ? (preporuka.korisnik!.slika!.startsWith('http')
                            ? NetworkImage(preporuka.korisnik!.slika!)
                            : MemoryImage(base64Decode(preporuka.korisnik!.slika!))) as ImageProvider
                        : null,
                    child: preporuka.korisnik!.slika == null 
                        ? Icon(Icons.person, color: Colors.white, size: 20)
                        : null,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '${preporuka.korisnik!.ime} ${preporuka.korisnik!.prezime}',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
            ],
            
            if (preporuka.razlogPreporuke != null) ...[
              Text(
                preporuka.razlogPreporuke!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 16),
            ],
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _prihvatiPreporuku(preporuka),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Prihvati preporuku',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Ponedjeljak', 'Utorak', 'Srijeda', 'Četvrtak', 
      'Petak', 'Subota', 'Nedjelja'
    ];
    return weekdays[weekday - 1];
  }
}