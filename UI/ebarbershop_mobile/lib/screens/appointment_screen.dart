import 'dart:convert';
import 'package:ebarbershop_mobile/models/lista_cekanja.dart';
import 'package:ebarbershop_mobile/models/mail_object.dart';
import 'package:ebarbershop_mobile/providers/lista_cekanja_provider.dart';
import 'package:ebarbershop_mobile/providers/mail_provider.dart';
import 'package:ebarbershop_mobile/providers/my_waiting_list_screen.dart';
import 'package:ebarbershop_mobile/screens/notification_service.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';
import 'package:ebarbershop_mobile/providers/rezervacija_provider.dart';
import 'package:ebarbershop_mobile/providers/termin_provider.dart';
import 'package:ebarbershop_mobile/screens/predvidjanje_zauzetosti_screen.dart' as zauzetost;
import 'package:ebarbershop_mobile/screens/preporuke_termina_screen.dart' as preporuke;

class AppointmentTimeScreen extends StatefulWidget {
  final Korisnik employee;
  final Usluga service;
  final DateTime selectedDate;
  final Korisnik klijent;

  const AppointmentTimeScreen({
    Key? key, 
    required this.employee, 
    required this.service,
    required this.selectedDate,
    required this.klijent,
  }) : super(key: key);

  @override
  _AppointmentTimeScreenState createState() => _AppointmentTimeScreenState();
}

class _AppointmentTimeScreenState extends State<AppointmentTimeScreen> {
  bool isLoading = true;
  bool isCreatingReservation = false;
  List<TimeSlot> availableTimeSlots = [];
  TimeSlot? selectedTimeSlot;
  late TerminProvider _terminProvider;

  @override
  void initState() {
    super.initState();
    _terminProvider = context.read<TerminProvider>();
    loadAvailableTimeSlots();
  }

  Future<void> loadAvailableTimeSlots() async {
    setState(() => isLoading = true);
    
    try {
      final appointments = await _terminProvider.get(filter: {
        'korisnikId': widget.employee.korisnikId.toString(),
        'datum': DateFormat('yyyy-MM-dd').format(widget.selectedDate),
      });

      final allSlots = List.generate(9, (index) {
        final hour = 9 + index;
        return TimeSlot(
          DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
            hour,
            0,
          ),
          true, 
        );
      });

      if (appointments?.result != null) {
        for (final appointment in appointments!.result!) {
          if (appointment.vrijeme != null) {
            final appointmentTime = appointment.vrijeme!;
            for (final slot in allSlots) {
              if (slot.time.hour == appointmentTime.hour) {
                slot.isAvailable = false;
                break;
              }
            }
          }
        }
      }

      setState(() {
        availableTimeSlots = allSlots;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri učitavanju termina: $e')),
      );
    }
  }
  Future<void> _joinWaitingList() async {
  if (widget.klijent.korisnikId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Morate biti prijavljeni da biste se pridružili listi čekanja')),
    );
    return;
  }

  final now = DateTime.now();
  final zeljeniDatum = widget.selectedDate;

  // Check if date is in the past
  if (zeljeniDatum.isBefore(DateTime(now.year, now.month, now.day))) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ne možete se pridružiti listi čekanja za prošle dane')),
    );
    return;
  }

  // Show time picker if no time slot is selected
  TimeOfDay? selectedTime;
  if (selectedTimeSlot != null) {
    selectedTime = TimeOfDay.fromDateTime(selectedTimeSlot!.time);
  } else {
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime == null) return;
  }

  try {
    final listaCekanjaProvider = context.read<ListaCekanjaProvider>();
    
    // 1. First check for existing waiting list entries
    final existingEntries = await listaCekanjaProvider.getByFrizerAndDate(
      frizerId: widget.employee.korisnikId!,
      datum: widget.selectedDate,
    );

    // 2. Check if user already has an entry for this time
    final timeString = "${selectedTime.hour.toString().padLeft(2,'0')}:${selectedTime.minute.toString().padLeft(2,'0')}:00";
    final hasExisting = existingEntries.any((entry) => 
      entry.klijentId == widget.klijent.korisnikId &&
      entry.zeljeniDatum == timeString
    );

    if (hasExisting) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Već ste na listi čekanja za ovaj termin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 3. Create new waiting list entry
    final request = ListaCekanjaInsertRequest(
      frizerId: widget.employee.korisnikId!,
      klijentId: Authorization.userId!,
      uslugaId: widget.service.uslugaId!,
      zeljeniDatum: DateTime(
        zeljeniDatum.year,
        zeljeniDatum.month,
        zeljeniDatum.day,
      ),
      zeljenoVrijeme: selectedTime,
      napomena: 'Želim termin u ${selectedTime.format(context)}',
      daniDoIsteka: 7,
    );

    debugPrint('Sending request: ${request.toJson()}');
    final result = await listaCekanjaProvider.joinWaitingList(request);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uspješno dodani na listu čekanja!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  } catch (e) {
    debugPrint("Full error: $e");
    
    // Handle specific API error message
    String errorMessage = 'Greška pri pridruživanju listi čekanja';
    if (e.toString().contains('Već ste na listi čekanja')) {
      errorMessage = 'Već ste na listi čekanja za ovaj termin';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Widget _buildWaitingListButton() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: OutlinedButton(
      onPressed: _joinWaitingList,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Theme.of(context).primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        'Pridruži se listi čekanja',
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).primaryColor,
        ),
      ),
    ),
  );
}
 Widget _buildActionButtons() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showRecommendations(),
                icon: Icon(Icons.auto_awesome, size: 20),
                label: Text('Preporuke'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showBusynessPrediction(),
                icon: Icon(Icons.analytics, size: 20),
                label: Text('Zauzetost'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyWaitingListScreen()),
                  );
                },
                child: Text('Moje liste čekanja'),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // //  Test dugmad
        //  Row(
        //    children: [
        //      Expanded(
        //        child: ElevatedButton.icon(
        //          onPressed: _testNotification,
        //          icon: Icon(Icons.notifications, size: 20),
        //          label: Text('Test'),
        //          style: ElevatedButton.styleFrom(
        //            backgroundColor: Colors.green[800],
        //            foregroundColor: Colors.white,
        //            padding: EdgeInsets.symmetric(vertical: 8),
        //          ),
        //        ),
        //      ),
        //      SizedBox(width: 12),
        //      Expanded(
        //        child: ElevatedButton.icon(
        //          onPressed: _checkNotifications,
        //          icon: Icon(Icons.list, size: 20),
        //          label: Text('Provjeri'),
        //          style: ElevatedButton.styleFrom(
        //            backgroundColor: Colors.purple[800],
        //            foregroundColor: Colors.white,
        //            padding: EdgeInsets.symmetric(vertical: 8),
        //          ),
        //        ),
        //      ),
        //    ],
        //  ),
      ],
    ),
  );
}
 
  void _showRecommendations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => preporuke.PreporukeTerminaScreen(
          usluga: widget.service,
        ),
      ),
    );
  }

  void _showBusynessPrediction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => zauzetost.PredvidjanjeZauzetostiScreen(
          frizer: widget.employee,
          usluga: widget.service,
        ),
      ),
    );
  }

  Future<void> _createReservation() async {
  if (selectedTimeSlot == null || !mounted) return;

  widget.klijent.korisnikId = Authorization.userId;
  
  if (widget.klijent.korisnikId == null) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Morate biti prijavljeni da biste rezervisali termin')),
    );
    return;
  }
  
  setState(() {
    isCreatingReservation = true;
  });

  try {
    final rezervacijaProvider = context.read<RezervacijaProvider>();
    final terminProvider = context.read<TerminProvider>();
    
    final reservationDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      selectedTimeSlot!.time.hour,
      selectedTimeSlot!.time.minute,
    );

    // Provjeri da li je rezervacija u budućnosti
    if (reservationDateTime.isBefore(DateTime.now())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ne možete rezervisati termin u prošlosti'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final createdReservation = await rezervacijaProvider.createReservation(
      datumRezervacije: DateTime.now(),
      korisnikId: widget.employee.korisnikId!,
      klijentId: widget.klijent.korisnikId!,
      uslugaId: widget.service.uslugaId!,
    );
    
    await terminProvider.insert({
      "vrijeme": reservationDateTime.toIso8601String(),
      "rezervacijaId": createdReservation.rezervacijaId,
      "korisnikID": widget.employee.korisnikId,
      "klijentId": widget.klijent.korisnikId!,
      "isBooked": true,
    });

    // Sigurno zakaži notifikaciju
    try {
      await NotificationService().scheduleReservationReminder(
        id: createdReservation.rezervacijaId!, 
        title: 'Podsjetnik za rezervaciju',
        body: 'Imate rezervaciju kod ${widget.employee.ime} ${widget.employee.prezime}',
        reservationTime: reservationDateTime,
      );
    } catch (notificationError) {
      // Ne prekidaj proces rezervacije ako notifikacija ne uspije
      print('Greška pri zakazivanju notifikacije: $notificationError');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rezervacija uspješno kreirana'), 
          backgroundColor: Colors.green,
        ),
      );
    }
    
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri kreiranju rezervacije: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        isCreatingReservation = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final formattedDate = "${widget.selectedDate.day}.${widget.selectedDate.month}.${widget.selectedDate.year}";
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Odabir termina'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[900],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datum: $formattedDate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
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
                                  widget.service.naziv ?? 'Nepoznata usluga',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Cijena: ${widget.service.cijena?.toStringAsFixed(2)} BAM',
                                  style: TextStyle(color: Colors.grey[300]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                _buildActionButtons(), // Dodana dugmad ovdje
                
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: widget.employee.slika != null && widget.employee.slika!.isNotEmpty
                          ? (widget.employee.slika!.startsWith('http')
                              ? NetworkImage(widget.employee.slika!)
                              : MemoryImage(base64Decode(widget.employee.slika!))) as ImageProvider
                          : null,
                        child: widget.employee.slika == null 
                          ? Icon(Icons.person, color: Colors.white)
                          : null,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.employee.ime} ${widget.employee.prezime}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Frizer',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Divider(height: 1),
                
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Dostupni termini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                availableTimeSlots.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            'Nema dostupnih termina za odabrani datum',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    : Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: availableTimeSlots.length,
                          itemBuilder: (context, index) {
                            final slot = availableTimeSlots[index];
                            return _buildTimeSlot(slot);
                          },
                        ),
                      ),
                
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: ElevatedButton(
                    onPressed: selectedTimeSlot == null || isCreatingReservation
                        ? null
                        : _createReservation,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: isCreatingReservation
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Potvrdi rezervaciju',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                _buildWaitingListButton(),
              ],
            ),
    );
  }

  Widget _buildTimeSlot(TimeSlot slot) {
    final isSelected = selectedTimeSlot == slot;
    final hour = slot.time.hour.toString().padLeft(2, '0');
    final minute = slot.time.minute.toString().padLeft(2, '0');
    
    return GestureDetector(
      onTap: slot.isAvailable
          ? () {
              setState(() {
                selectedTimeSlot = slot;
              });
            }
          : null,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: !slot.isAvailable
              ? Colors.grey[800]
              : isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Text(
          '$hour:$minute',
          style: TextStyle(
             color: !slot.isAvailable
              ? Colors.grey
              : isSelected
                  ? Colors.black  
                  : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class TimeSlot {
  final DateTime time;
  bool isAvailable;

  TimeSlot(this.time, this.isAvailable);
}