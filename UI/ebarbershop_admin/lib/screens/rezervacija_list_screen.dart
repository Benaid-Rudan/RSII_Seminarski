import 'package:ebarbershop_admin/models/rezervacija.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class RezervacijaListScreen extends StatefulWidget {
  RezervacijaListScreen({super.key});

  @override
  State<RezervacijaListScreen> createState() => _RezervacijaListScreenState();
}

class _RezervacijaListScreenState extends State<RezervacijaListScreen> {
  late RezervacijaProvider _rezervacijaProvider;
  SearchResult<Rezervacija>? result;
  Map<DateTime, List<Rezervacija>> _events = {};
  List<Rezervacija> _selectedDayReservations = [];

  TextEditingController _imePrezimeController = TextEditingController();
  TextEditingController _datumController = TextEditingController();
  bool _isLoading = false;
  bool _showCalendarView = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
      "IncludeKlijent": true,
      "imePrezimeKlijenta": _imePrezimeController.text,
      "DatumRezervacijeBezVremena": isoDatum
    });

    setState(() {
      result = data;
      _processReservationsForCalendar();
      _isLoading = false;
    });
  }

  void _processReservationsForCalendar() {
    _events = {};
    if (result == null || result!.result.isEmpty) return;

    for (var rezervacija in result!.result) {
      if (rezervacija.datumRezervacije != null) {
        // Strip time part to get just the date
        final date = DateTime(
          rezervacija.datumRezervacije!.year,
          rezervacija.datumRezervacije!.month,
          rezervacija.datumRezervacije!.day,
        );
        
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add(rezervacija);
      }
    }

    // If a date is selected, update the selected day reservations
    if (_selectedDay != null) {
      _updateSelectedDayReservations();
    }
  }

  void _updateSelectedDayReservations() {
    final selectedDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    
    _selectedDayReservations = _events[selectedDate] ?? [];
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

  List<Rezervacija> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _updateSelectedDayReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearch(),
        _buildViewToggle(),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : _showCalendarView
                ? _buildCalendarView()
                : _buildDataListView(),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ToggleButtons(
            isSelected: [_showCalendarView, !_showCalendarView],
            onPressed: (index) {
              setState(() {
                _showCalendarView = index == 0;
              });
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: Colors.blueGrey,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(width: 8),
                    Text('Kalendar'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('Tabela'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
                controller: _imePrezimeController,
                decoration: InputDecoration(
                  labelText: "Ime i prezime",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                onChanged: (value) {
                  _loadData();
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _datumController,
                    decoration: InputDecoration(
                      labelText: "Datum rezervacije",
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
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Expanded(
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.blueGrey,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueGrey,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
              ),
            ),
          ),
          SizedBox(height: 8),
          _selectedDay != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Rezervacije za ${DateFormat('dd.MM.yyyy').format(_selectedDay!)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : SizedBox(),
          _selectedDay != null
              ? _buildSelectedDayReservations()
              : Expanded(
                  child: Center(
                    child: Text('Odaberite datum da vidite rezervacije'),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayReservations() {
    if (_selectedDayReservations.isEmpty) {
      return Expanded(
        child: Center(
          child: Text('Nema rezervacija za odabrani datum'),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _selectedDayReservations.length,
        itemBuilder: (context, index) {
          final rezervacija = _selectedDayReservations[index];
          final formattedTime = DateFormat('HH:mm').format(rezervacija.datumRezervacije!);
          
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[850],
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Text(formattedTime),
              ),
              title: Text(
                '${rezervacija.klijent?.ime ?? ''} ${rezervacija.klijent?.prezime ?? ''}',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Usluga: ${rezervacija.usluga?.naziv ?? ''}',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(rezervacija),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(Rezervacija rezervacija) async {
    bool? potvrda = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Potvrda"),
        content: Text("Da li ste sigurni da želite obrisati ovu rezervaciju?"),
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
        await _rezervacijaProvider.delete(rezervacija.rezervacijaId!);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rezervacija uspješno obrisana'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
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
              label: Expanded(
                child: Text(
                  'ID',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Ime i prezime',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Datum rezervacije',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Usluga',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Akcije',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          rows: result?.result.asMap().entries.map((entry) {
                int index = entry.key;
                Rezervacija e = entry.value;

                // Format date in a user-friendly way
                String formattedDate = "";
                if (e.datumRezervacije != null) {
                  formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(e.datumRezervacije!);
                }

                return DataRow(
                  color: MaterialStateColor.resolveWith(
                    (states) =>
                        index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!,
                  ),
                  cells: [
                    DataCell(Text(e.rezervacijaId.toString() ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(
                        "${e.klijent?.ime ?? ''} ${e.klijent?.prezime ?? ''}",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(formattedDate,
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(e.usluga?.naziv ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(e),
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
}