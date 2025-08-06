import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ebarbershop_mobile/models/predvidjanje_zauzetosti.dart';
import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/providers/predvidjanje_zauzetosti_provider.dart';

class PredvidjanjeZauzetostiScreen extends StatefulWidget {
  final Korisnik frizer;
  
  const PredvidjanjeZauzetostiScreen({Key? key, required this.frizer}) : super(key: key);

  @override
  _PredvidjanjeZauzetostiScreenState createState() => _PredvidjanjeZauzetostiScreenState();
}

class _PredvidjanjeZauzetostiScreenState extends State<PredvidjanjeZauzetostiScreen> {
  late PredvidjanjeZauzetostiProvider _predvidjanjeProvider;
  PredvidjanjeZauzetosti? _predvidjanje;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _predvidjanjeProvider = context.read<PredvidjanjeZauzetostiProvider>();
    _loadPredvidjanje();
  }

  Future<void> _loadPredvidjanje() async {
    try {
      setState(() => _isLoading = true);
      
      final predvidjanje = await _predvidjanjeProvider.predvidiZauzetost(
        widget.frizer.korisnikId!,
        _selectedDate,
      );

      if (mounted) {
        setState(() {
          _predvidjanje = predvidjanje;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri učitavanju predviđanja: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amber[800]!,
              onPrimary: Colors.white,
              surface: Colors.grey[850]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadPredvidjanje();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predviđanje zauzetosti'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          if (_predvidjanje != null) ...[
            _buildOverallBusyness(),
            _buildHourlyBusyness(),
            _buildRecommendedSlots(),
          ] else
            _buildErrorState(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final String formattedDate = DateFormat('EEEE, dd.MM.yyyy', 'hr_HR').format(_selectedDate);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      color: Colors.grey[900],
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: widget.frizer.slika != null && widget.frizer.slika!.isNotEmpty
                ? NetworkImage(widget.frizer.slika!)
                : null,
            child: widget.frizer.slika == null 
                ? Icon(Icons.person, color: Colors.white, size: 30)
                : null,
          ),
          SizedBox(height: 12),
          Text(
            '${widget.frizer.ime} ${widget.frizer.prezime}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[800]?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber[800]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, color: Colors.amber[800], size: 16),
                  SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallBusyness() {
    final double ukupnaZauzetost = _predvidjanje!.ukupnaZauzetost ?? 0.0;
    final int procenat = (ukupnaZauzetost * 100).round();
    
    Color color = ukupnaZauzetost < 0.3 
        ? Colors.green 
        : ukupnaZauzetost < 0.7 
            ? Colors.orange 
            : Colors.red;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        children: [
          Text(
            'Ukupna zauzetost',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: ukupnaZauzetost,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  '$procenat%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            _getBusynessDescription(ukupnaZauzetost),
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyBusyness() {
    final Map<String, double> zauzetostPoSatima = _predvidjanje!.zauzetostPoSatima ?? {};
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zauzetost po satima',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...zauzetostPoSatima.entries.map((entry) => _buildHourRow(entry.key, entry.value)).toList(),
        ],
      ),
    );
  }

  Widget _buildHourRow(String hour, double zauzetost) {
    final int procenat = (zauzetost * 100).round();
    Color color = zauzetost < 0.3 
        ? Colors.green 
        : zauzetost < 0.7 
            ? Colors.orange 
            : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$hour:00',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: zauzetost,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '$procenat%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSlots() {
    final List<String> preporuceniTermini = _predvidjanje!.preporuceniTermini ?? [];
    
    if (preporuceniTermini.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade700),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              'Nema preporučenih termina',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Dan je vrlo zauzet, pokušajte drugi datum',
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

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: Colors.green,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Preporučeni termini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: preporuceniTermini.map((termin) => _buildTimeChip(termin)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String time) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Greška pri učitavanju',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pokušajte ponovo odabrati datum',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPredvidjanje,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
            ),
            child: Text('Pokušaj ponovo'),
          ),
        ],
      ),
    );
  }

  String _getBusynessDescription(double zauzetost) {
    if (zauzetost < 0.3) {
      return 'Veoma slobodan dan - idealno za rezervacije';
    } else if (zauzetost < 0.5) {
      return 'Umjereno zauzet dan - dobra dostupnost';
    } else if (zauzetost < 0.7) {
      return 'Zauzet dan - ograničena dostupnost';
    } else {
      return 'Veoma zauzet dan - preporučujemo drugi datum';
    }
  }
}