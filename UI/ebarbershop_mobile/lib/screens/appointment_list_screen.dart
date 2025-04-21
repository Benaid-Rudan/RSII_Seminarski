import 'package:ebarbershop_mobile/providers/rezervacija_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ebarbershop_mobile/providers/termin_provider.dart';
import 'package:ebarbershop_mobile/models/termin.dart';
import 'package:ebarbershop_mobile/providers/usluga_provider.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';

class AppointmentListScreen extends StatefulWidget {
  static const String routeName = "/termini";

  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  late TerminProvider _terminProvider;
  late UslugaProvider _uslugaProvider;
  late RezervacijaProvider _rezervacijaProvider;
  List<Termin> _termini = [];
  bool _isLoading = true;
  bool _showUpcoming = true;
  Map<int, String> _uslugaNazivi = {};

  @override
  void initState() {
    super.initState();
    _terminProvider = context.read<TerminProvider>();
    _uslugaProvider = context.read<UslugaProvider>();
    _rezervacijaProvider = context.read<RezervacijaProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
  try {
    setState(() => _isLoading = true);
    
    // Get the current user's ID
    final currentUserId = Authorization.userId;
    
    if (currentUserId == null) {
      throw Exception("User not logged in");
    }

    // Get appointments with filters
    var terminData = await _terminProvider.get(
      filter: {
        'includeRezervacija': true, 
        'includeUsluga': true,
        'rezervacija.klijentId': currentUserId.toString(), // Filter by current user
      }
    );
    
    var uslugaData = await _uslugaProvider.get();

    _uslugaNazivi = {
      for (var u in uslugaData.result!) u.uslugaId!: u.naziv!,
    };

    if (mounted) {
      setState(() {
        _termini = terminData?.result ?? [];
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri učitavanju termina: ${e.toString()}")),
      );
    }
  }
}

  Future<void> _refreshAppointments() async {
    await _loadData();
  }

  List<Termin> get _upcomingTermini {
  final now = DateTime.now();
  return _termini
      .where((termin) => 
          termin.vrijeme != null && 
          termin.vrijeme!.isAfter(now) &&
          termin.rezervacija?.klijentId == Authorization.userId)
      .toList()
    ..sort((a, b) => a.vrijeme!.compareTo(b.vrijeme!));
}

List<Termin> get _pastTermini {
  final now = DateTime.now();
  return _termini
      .where((termin) => 
          termin.vrijeme != null && 
          termin.vrijeme!.isBefore(now) &&
          termin.rezervacija?.klijentId == Authorization.userId)
      .toList()
    ..sort((a, b) => b.vrijeme!.compareTo(a.vrijeme!));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moji termini'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.blueGrey,
      body: RefreshIndicator(
        onRefresh: _refreshAppointments,
        child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
                child: Column(
                  children: [
                    _buildToggleButtons(),
                    Divider(color: Colors.grey.shade700, thickness: 1),
                    Expanded(
                      child: _showUpcoming 
                          ? _buildTerminiList(_upcomingTermini, 'Trenutno nemate termina')
                          : _buildTerminiList(_pastTermini, 'Nemate prošlih termina'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToggleButton('Budući', _showUpcoming, () => setState(() => _showUpcoming = true)),
          SizedBox(width: 40),
          _buildToggleButton('Prošli', !_showUpcoming, () => setState(() => _showUpcoming = false)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.amber[800] : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildTerminiList(List<Termin> termini, String emptyMessage) {
    if (termini.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[300], fontSize: 16),
            ),
            if (_showUpcoming) SizedBox(height: 10),
            if (_showUpcoming) Text(
              'Samo nekoliko klikova dijeli vas od vašeg termina.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: termini.length,
      itemBuilder: (context, index) => _buildTerminCard(termini[index]),
    );
  }

  Widget _buildTerminCard(Termin termin) {
    final DateTime date = termin.vrijeme!;
    final String month = _getMonthAbbreviation(date.month);
    final String day = date.day.toString();
    final String time = DateFormat('HH:mm').format(date);
    final String weekday = _getWeekdayName(date.weekday);
    final String fullDate = '$weekday, ${date.day}. ${_getMonthName(date.month)} ${date.year}.';
    
    final uslugaNaziv = _getUslugaNaziv(termin);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade800),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expanded date section
          Container(
            width: 90,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), 
                bottomLeft: Radius.circular(8)
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(month, style: _whiteBoldTextStyle18),
                SizedBox(height: 8),
                Text(day, style: _whiteBoldTextStyle28),
                SizedBox(height: 8),
                Text(time, style: _whiteBoldTextStyle18),
              ],
            ),
          ),
          
          // Content section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(uslugaNaziv, style: _whiteBoldTextStyle18),
                  SizedBox(height: 8),
                  Text('${time} - ${_getEndTime(date, 30)}', style: _whiteBoldTextStyle18),
                  SizedBox(height: 8),
                  Text('$fullDate', style: _whiteBoldTextStyle18, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
          
          // Cancel button (only for upcoming appointments)
          if (date.isAfter(DateTime.now()))
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 8),
              child: IconButton(
                icon: Icon(Icons.cancel, color: Colors.red.shade700, size: 30),
                onPressed: () => _potvrdiBrisanje(termin),
              ),
            ),
        ],
      ),
    );
  }

  String _getUslugaNaziv(Termin termin) {
    if (termin.rezervacija?.usluga?.naziv != null) {
      return termin.rezervacija!.usluga!.naziv!;
    }
    if (termin.rezervacija?.uslugaId != null) {
      return _uslugaNazivi[termin.rezervacija!.uslugaId] ?? 'Nepoznata usluga';
    }
    return 'Nepoznata usluga';
  }

  Future<void> _potvrdiBrisanje(Termin termin) async {
    bool? potvrda = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Potvrda otkazivanja"),
        content: Text("Da li ste sigurni da želite otkazati termin?"),
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

    if (potvrda == true) {
      try {
        // Zatim obriši termin
        await _terminProvider.delete(termin.terminId!);
        // Prvo obriši rezervaciju ako postoji
        if (termin.rezervacijaId != null) {
          await _rezervacijaProvider.delete(termin.rezervacijaId!);
        }
        
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Termin i rezervacija uspješno obrisani")),
        );
        
        await _refreshAppointments();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri brisanju: ${e.toString()}")),
        );
      }
    }
  }

  // Stilovi
  final TextStyle _whiteBoldTextStyle28 = TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold);
  final TextStyle _whiteBoldTextStyle18 = TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);

  // Pomoćne metode za datume
  String _getMonthAbbreviation(int month) => ['Jan', 'Feb', 'Mar', 'Apr', 'Maj', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dec'][month - 1];
  
  String _getMonthName(int month) => ['Januar', 'Februar', 'Mart', 'April', 'Maj', 'Juni', 'Juli', 'August', 'Septembar', 'Oktobar', 'Novembar', 'Decembar'][month - 1];
  
  String _getWeekdayName(int weekday) => ['Ponedjeljak', 'Utorak', 'Srijeda', 'Četvrtak', 'Petak', 'Subota', 'Nedjelja'][weekday - 1];
  
  String _getEndTime(DateTime startTime, int durationMinutes) => 
      DateFormat('HH:mm').format(startTime.add(Duration(minutes: durationMinutes)));
}