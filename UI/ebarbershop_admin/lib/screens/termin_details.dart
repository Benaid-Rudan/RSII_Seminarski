// ignore_for_file: sort_child_properties_last

import 'package:ebarbershop_admin/models/rezervacija.dart';
import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/termin.dart';
import 'package:ebarbershop_admin/providers/korisnik_provider.dart';
import 'package:ebarbershop_admin/providers/termin_provider.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class TerminDetailsScreen extends StatefulWidget {
  Termin? termin;
  TerminDetailsScreen({super.key, this.termin});

  @override
  State<TerminDetailsScreen> createState() => _TerminDetailsScreenState();
}

class _TerminDetailsScreenState extends State<TerminDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late TerminProvider _terminProvider;
  bool isLoading = true;
  SearchResult<Korisnik>? korisnikResult;
  late KorisnikProvider _korisnikProvider;

  @override
  void initState() {
    super.initState();
    _terminProvider = context.read<TerminProvider>();

    _initialValue = {
      'terminId': widget.termin?.terminId,
      'terminUposelnik': widget.termin?.terminUposelnik,
      'vrijeme': widget.termin?.vrijeme != null
          ? DateTime.parse(widget.termin!.vrijeme!.toString())
          : null, // Konverzija String u DateTime
      'rezervacijaId': widget.termin?.rezervacijaId.toString(),
      'isBooked': widget.termin?.isBooked ?? false,
      'korisnikID': widget.termin?.korisnikID.toString(),
    };
    _korisnikProvider = context.read<KorisnikProvider>();

    initForm();
  }

  Future initForm() async {
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
                    try {
                      final formData = Map<String, dynamic>.from(
                          _formKey.currentState!.value);

                      // Convert DateTime to string format
                      if (formData['vrijeme'] is DateTime) {
                        formData['vrijeme'] =
                            (formData['vrijeme'] as DateTime).toIso8601String();
                      }

                      if (widget.termin == null) {
                        await _terminProvider.insert(formData);
                      } else {
                        await _terminProvider.update(
                            widget.termin!.terminId!, formData);
                      }
                    } on Exception catch (e) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text("Greška"),
                          content: Text(e.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  child: Text("Sačuvaj"),
                ),
              ),
            ],
          )
        ],
      ),
      title: widget.termin?.terminUposelnik ?? "Detalji termina",
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValue,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderDateTimePicker(
                  name: "vrijeme",
                  decoration: InputDecoration(labelText: "Vrijeme termina"),
                  inputType: InputType.both,
                ),
              ),
            ],
          ),
          // Row(
          //   children: [
          //     Expanded(
          //       child: FormBuilderSwitch(
          //         name: "isBooked",
          //         title: Text("Rezervisano"),
          //       ),
          //     ),
          //   ],
          // ),
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown<String>(
                  name: 'korisnikId',
                  decoration: InputDecoration(
                    labelText: 'Korisnik',
                  ),
                  items: (korisnikResult?.result ?? [])
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
                child: FormBuilderTextField(
                  name: "rezervacijaId",
                  decoration: InputDecoration(labelText: "Rezervacija ID"),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
