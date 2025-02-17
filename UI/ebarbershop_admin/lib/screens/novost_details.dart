// ignore_for_file: sort_child_properties_last

import 'package:ebarbershop_admin/models/novost.dart';
import 'package:ebarbershop_admin/providers/novost_provider.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class NovostDetailsScreen extends StatefulWidget {
  Novost? novost;
  NovostDetailsScreen({super.key, this.novost});

  @override
  State<NovostDetailsScreen> createState() => _NovostDetailsScreenState();
}

class _NovostDetailsScreenState extends State<NovostDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late NovostProvider _novostProvider;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _novostProvider = context.read<NovostProvider>();

    // Initialize form values with the existing `novost` data
    _initialValue = {
      'novostId': widget.novost?.novostId,
      'naslov': widget.novost?.naslov,
      'sadrzaj': widget.novost?.sadrzaj,
      'datumObjave': widget.novost?.datumObjave?.toIso8601String(),
      'slika': widget.novost?.slika,
    };

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
                      if (widget.novost == null) {
                        // Insert a new novost
                        await _novostProvider
                            .insert(_formKey.currentState?.value);
                      } else {
                        // Update existing novost
                        await _novostProvider.update(
                          widget.novost!.novostId!,
                          _formKey.currentState!.value,
                        );
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
                                child: Text("OK"))
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
      title: widget.novost?.naslov ?? "Detalji novosti",
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
                child: FormBuilderTextField(
                  name: "naslov",
                  decoration: InputDecoration(labelText: "Naslov"),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "sadrzaj",
                  decoration: InputDecoration(labelText: "Sadržaj"),
                  maxLines: 5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "datumObjave",
                  decoration: InputDecoration(labelText: "Datum objave"),
                  keyboardType: TextInputType.datetime,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "slika",
                  decoration: InputDecoration(labelText: "Slika URL"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
