// service_selection_screen.dart
import 'package:ebarbershop_mobile/screens/appointment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/usluga.dart';
import 'package:ebarbershop_mobile/providers/usluga_provider.dart';
import 'package:intl/intl.dart';

class ServiceSelectionScreen extends StatefulWidget {
  final Korisnik employee;
  final Korisnik klijent;

  const ServiceSelectionScreen({Key? key, required this.employee, required this.klijent}) : super(key: key);

  @override
  _ServiceSelectionScreenState createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  late UslugaProvider _uslugaProvider;
  bool isLoading = true;
  List<Usluga>? services;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _uslugaProvider = context.read<UslugaProvider>();
    loadServices();
    selectedDate = DateTime.now();
  }

  Future<void> loadServices() async {
    setState(() {
      isLoading = true;
    });
    try {
      var data = await _uslugaProvider.get();
      setState(() {
        services = data.result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri učitavanju usluga: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usluge & Cjenovnik'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date selection row
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white),
                      SizedBox(width: 16),
                      Text(
                        'Datum:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          selectedDate != null
                              ? DateFormat('dd.MM.yyyy').format(selectedDate!)
                              : 'Odaberite datum',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Services list
                Expanded(
                  child: _buildServicesList(),
                ),
              ],
            ),
    );
  }

  Widget _buildServicesList() {
    if (services == null || services!.isEmpty) {
      return Center(
        child: Text("Nema dostupnih usluga"),
      );
    }

    return ListView.builder(
      itemCount: services!.length,
      itemBuilder: (context, index) {
        final service = services![index];
        return Column(
          children: [
            if (index == 0) SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.cut,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.naziv ?? 'Nepoznata usluga',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          service.opis ?? '',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Cijena: ${service.cijena?.toStringAsFixed(2)} BAM',
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedDate == null
                                ? null
                                : () {                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AppointmentTimeScreen(
                                          employee: widget.employee,
                                          service: service,
                                          selectedDate: selectedDate!,
                                          klijent: widget.klijent,
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                            ),
                            
                          ), child: Text('Rezerviši'),
                        ),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (index < services!.length - 1)
              Divider(
                color: Colors.grey[800],
                height: 24,
                indent: 16,
                endIndent: 16,
              ),
          ],
        );
      },
    );
  }
}