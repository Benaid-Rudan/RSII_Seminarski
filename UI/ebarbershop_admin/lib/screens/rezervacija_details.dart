// ignore_for_file: sort_child_properties_last

import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/models/rezervacija.dart'; // Model za rezervaciju
import 'package:ebarbershop_admin/models/search_result.dart'; // Ako imate search result za usluge ili korisnike
import 'package:ebarbershop_admin/models/usluga.dart';
import 'package:ebarbershop_admin/providers/korisnik_provider.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart'; // Provider za rezervacije
import 'package:ebarbershop_admin/providers/usluga_provider.dart'; // Provider za usluge
import 'package:ebarbershop_admin/widgets/master_screen.dart'; // Vaš MasterScreen widget
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class RezervacijaDetailsScreen extends StatefulWidget {
  final Rezervacija? rezervacija;

  RezervacijaDetailsScreen({super.key, this.rezervacija});

  @override
  State<RezervacijaDetailsScreen> createState() =>
      _RezervacijaDetailsScreenState();
}

class _RezervacijaDetailsScreenState extends State<RezervacijaDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initalValue = {};
  late UslugaProvider _uslugaProvider;
  late KorisnikProvider _korisnikProvider;

  late RezervacijaProvider _rezervacijaProvider;

  SearchResult<Usluga>? uslugaResult;
  SearchResult<Korisnik>? korisnikResult;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initalValue = {
      // Convert datumRezervacije to DateTime object if it's not null
      'datumRezervacije': widget.rezervacija?.datumRezervacije != null
          ? DateTime.parse(widget.rezervacija!.datumRezervacije!.toString())
          : null,
      'korisnikId': widget.rezervacija?.korisnikId?.toString(),
      'uslugaId': widget.rezervacija?.uslugaId?.toString(),
    };

    _uslugaProvider = context.read<UslugaProvider>();
    _korisnikProvider = context.read<KorisnikProvider>();
    _rezervacijaProvider = context.read<RezervacijaProvider>();

    initForm();
  }

  Future initForm() async {
    uslugaResult = await _uslugaProvider.get();
    korisnikResult = await _korisnikProvider.get();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      child: Column(
        children: [
          isLoading ? Container() : _buildForm(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () async {
                      _formKey.currentState?.saveAndValidate();
                      print(_formKey.currentState?.value);

                      try {
                        if (widget.rezervacija == null) {
                          await _rezervacijaProvider
                              .insert(_formKey.currentState?.value);
                        } else {
                          if (widget.rezervacija!.rezervacijaId != null) {
                            await _rezervacijaProvider.update(
                              widget.rezervacija!.rezervacijaId!,
                              _formKey.currentState!.value,
                            );
                          }
                        }
                      } on Exception catch (e) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: Text("Error"),
                                  content: Text(e.toString()),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("OK"))
                                  ],
                                ));
                      }
                    },
                    child: Text("Save")),
              ),
            ],
          ),
        ],
      ),
      title: widget.rezervacija?.datumRezervacije?.toString() ??
          "Reservation details",
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initalValue,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderDateTimePicker(
                  name: 'datumRezervacije',
                  inputType: InputType.both,
                  decoration: InputDecoration(labelText: "Datum rezervacije"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: FormBuilderDropdown<String>(
                  name: 'korisnikId',
                  decoration: InputDecoration(
                    labelText: 'Korisnik',
                  ),
                  items: (korisnikResult?.result ??
                          []) // Popuniti sa listom korisnika
                      .map((item) => DropdownMenuItem<String>(
                            value: item.korisnikId.toString(),
                            child: Text(item.ime ?? ""),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown<String>(
                  name: 'uslugaId',
                  decoration: InputDecoration(
                    labelText: 'Usluga',
                  ),
                  items: uslugaResult?.result
                          .map((item) => DropdownMenuItem<String>(
                                value: item.uslugaId.toString(),
                                child: Text(item.naziv ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
