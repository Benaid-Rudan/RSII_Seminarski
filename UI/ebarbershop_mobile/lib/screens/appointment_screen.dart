import 'dart:convert';

import 'package:ebarbershop_mobile/models/mail_object.dart';
import 'package:ebarbershop_mobile/providers/mail_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';
import 'package:ebarbershop_mobile/providers/rezervacija_provider.dart';
import 'package:ebarbershop_mobile/providers/termin_provider.dart';

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
    final mailProvider = context.read<MailProvider>();
    
    final reservationDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      selectedTimeSlot!.time.hour,
      selectedTimeSlot!.time.minute,
    );

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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email potvrde poslan na ${widget.klijent.email}'), backgroundColor: Colors.green,),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rezervacija uspješno kreirana'), backgroundColor: Colors.green,),
    );
    
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vratite se korak nazad i odaberite neki budući datum i vrijeme.'),backgroundColor: Colors.red,),
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