// employee_selection_screen.dart
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebarbershop_mobile/models/korisnik.dart';
import 'package:ebarbershop_mobile/models/search_result.dart';
import 'package:ebarbershop_mobile/providers/korisnik_provider.dart';
import 'package:ebarbershop_mobile/screens/service_selection_screen.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeSelectionScreen extends StatefulWidget {
  const EmployeeSelectionScreen({Key? key}) : super(key: key);

  @override
  _EmployeeSelectionScreenState createState() => _EmployeeSelectionScreenState();
}

class _EmployeeSelectionScreenState extends State<EmployeeSelectionScreen> {
  late KorisnikProvider _korisniciProvider;
  bool isLoading = true;
  SearchResult<Korisnik>? result;
  late Korisnik klijent;
  @override
  void initState() {
    super.initState();
    _korisniciProvider = context.read<KorisnikProvider>();
     loadKlijent();
    loadData();
  }
  Future<void> loadKlijent() async {
  var data = await _korisniciProvider.getById(Authorization.userId!);

  if (!mounted) return;
  setState(() {
    klijent = data;
  });
}
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var data = await _korisniciProvider.getEmployees();
      setState(() {
        result = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri učitavanju uposlenika: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Odaberite uposlenika"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildEmployeeList(),
    );
  }

  Widget _buildEmployeeList() {
    if (result == null || result!.result.isEmpty) {
      return Center(
        child: Text("Nema dostupnih uposlenika"),
      );
    }

    return ListView.builder(
      itemCount: result!.result.length,
      itemBuilder: (context, index) {
        final employee = result!.result[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
            backgroundImage: employee.slika != null && employee.slika!.isNotEmpty
                ? MemoryImage(base64Decode(employee.slika!))
                : null,
            child: employee.slika == null || employee.slika!.isEmpty
                ? Text(employee.ime?.substring(0, 1) ?? '')
                : null,
          ),
            title: Text(
              employee.fullName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Frizer"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ServiceSelectionScreen(employee: employee, klijent: klijent),
                ),
              );
            },

          ),
        );
      },
    );
  }
}