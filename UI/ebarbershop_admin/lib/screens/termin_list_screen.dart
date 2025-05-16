import 'package:ebarbershop_admin/models/rezervacija.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/termin.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart';
import 'package:ebarbershop_admin/providers/termin_provider.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class TerminListScreen extends StatefulWidget {
  TerminListScreen({super.key});

  @override
  State<TerminListScreen> createState() => _TerminListScreenState();
}

class _TerminListScreenState extends State<TerminListScreen> {
  late TerminProvider _terminProvider;

  SearchResult<Termin>? result;
  Map<DateTime, List<Termin>> _events = {};
  List<Termin> _selectedDayAppointments = [];

  bool _isLoading = false;
  bool _showCalendarView = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  TextEditingController _imePrezimeController = TextEditingController();
  TextEditingController _datumController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _terminProvider = context.read<TerminProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    String? isoDatum;
    if (_datumController.text.isNotEmpty) {
      try {
        final parsedDate =
            DateFormat('dd.MM.yyyy').parse(_datumController.text);
        isoDatum = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        print('Greška pri parsiranju datuma: $e');
      }
    }

    var data = await _terminProvider.get(filter: {
      "IncludeKorisnik": true,
      "IncludeRezervacija": true,
      "imePrezime": _imePrezimeController.text,
      "Datum": isoDatum,
    });

    setState(() {
      result = data;
      _processAppointmentsForCalendar();
      _isLoading = false;
    });
  }

  void _processAppointmentsForCalendar() {
    _events = {};
    if (result == null || result!.result.isEmpty) return;

    for (var termin in result!.result) {
      if (termin.vrijeme != null) {
        final date = DateTime(termin.vrijeme!.year, termin.vrijeme!.month,
            termin.vrijeme!.day);

        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add(termin);
      }
    }

    if (_selectedDay != null) {
      _updateSelectedDayAppointments();
    }
  }

  void _updateSelectedDayAppointments() {
    final selectedDate = DateTime(
        _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    _selectedDayAppointments = _events[selectedDate] ?? [];
  }

  List<Termin> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _updateSelectedDayAppointments();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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

  Widget _buildSearch() {
    return Card(
      color: Colors.blueGrey,
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                ),
                onChanged: (value) => _loadData(),
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
                      labelText: "Datum termina",
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.blueGrey[100],
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
                  children: [Icon(Icons.calendar_month), SizedBox(width: 8), Text('Kalendar')],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [Icon(Icons.table_chart), SizedBox(width: 8), Text('Tabela')],
                ),
              ),
            ],
          ),
        ],
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
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(color: Colors.blueGrey, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: Colors.blueGrey, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.5), shape: BoxShape.circle),
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
              ? Expanded(child: _buildSelectedDayAppointments())
              : Expanded(
                  child: Center(child: Text('Odaberite datum da vidite termine')),
                ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayAppointments() {
    if (_selectedDayAppointments.isEmpty) {
      return Center(child: Text('Nema termina za odabrani datum'));
    }

    return ListView.builder(
      itemCount: _selectedDayAppointments.length,
      itemBuilder: (context, index) {
        final termin = _selectedDayAppointments[index];
        final vrijeme = termin.vrijeme != null ? DateFormat('HH:mm').format(termin.vrijeme!) : '';

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.grey[850],
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Text(vrijeme),
            ),
            title: Text('${termin.korisnik?.ime ?? ''} ${termin.korisnik?.prezime ?? ''}',
                style: TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTermin(termin),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black),
          dataRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[900]!),
          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Frizer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Datum termina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Akcije', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: result?.result.asMap().entries.map((entry) {
            int index = entry.key;
            Termin e = entry.value;
            final formatted = e.vrijeme != null ? DateFormat('dd.MM.yyyy HH:mm').format(e.vrijeme!) : '';

            return DataRow(
              color: MaterialStateColor.resolveWith((states) => index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!),
              cells: [
                DataCell(Text(e.terminId.toString(), style: TextStyle(color: Colors.white))),
                DataCell(Text('${e.korisnik?.ime ?? ''} ${e.korisnik?.prezime ?? ''}',
                    style: TextStyle(color: Colors.white))),
                DataCell(Text(formatted, style: TextStyle(color: Colors.white))),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTermin(e),
                  ),
                ),
              ],
            );
          }).toList() ?? [],
        ),
      ),
    );
  }

  void _deleteTermin(Termin e) async {
    bool? potvrda = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Potvrda"),
        content: Text("Da li ste sigurni da želite obrisati ovaj termin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Ne")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Da")),
        ],
      ),
    );

    if (potvrda == true) {
      try {
        await _terminProvider.delete(e.terminId!);
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Termin uspješno obrisan'),
          backgroundColor: Colors.red,
        ));
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Greška"),
            content: Text(e.toString()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
            ],
          ),
        );
      }
    }
  }
}
