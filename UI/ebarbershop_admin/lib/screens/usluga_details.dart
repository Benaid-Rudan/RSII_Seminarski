import 'package:ebarbershop_admin/models/usluga.dart';
import 'package:ebarbershop_admin/providers/usluga_provider.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class UslugaDetailsScreen extends StatefulWidget {
  final Usluga? usluga;

  const UslugaDetailsScreen({super.key, this.usluga});

  @override
  State<UslugaDetailsScreen> createState() => _UslugaDetailsScreenState();
}

class _UslugaDetailsScreenState extends State<UslugaDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late UslugaProvider _uslugaProvider;
  bool isLoading = true;

  Map<String, dynamic> _initialValue = {};

  @override
  void initState() {
    super.initState();
    _uslugaProvider = context.read<UslugaProvider>();

    _initialValue = {
      'naziv': widget.usluga?.naziv ?? '',
      'opis': widget.usluga?.opis ?? '',
      'cijena': widget.usluga?.cijena?.toString() ?? '0.00',
    };

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.usluga?.naziv ?? "Detalji usluge",
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildForm(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () async {
                          _formKey.currentState?.saveAndValidate();
                          print(_formKey.currentState?.value);

                          try {
                            final formData = Map<String, dynamic>.from(
                                _formKey.currentState!.value);
                            formData['cijena'] =
                                double.tryParse(formData['cijena'] ?? '0.00');

                            if (widget.usluga == null) {
                              await _uslugaProvider.insert(formData);
                            } else {
                              await _uslugaProvider.update(
                                  widget.usluga!.uslugaId!, formData);
                            }
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text("Greška"),
                                content: Text(e.toString()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK"),
                                  )
                                ],
                              ),
                            );
                          }
                        },
                        child: const Text("Sačuvaj"),
                      ),
                    ),
                  ],
                )
              ],
            ),
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
                  name: "naziv",
                  decoration: const InputDecoration(labelText: "Naziv usluge"),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Obavezno polje' : null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "opis",
                  decoration: const InputDecoration(labelText: "Opis usluge"),
                  maxLines: 3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "cijena",
                  decoration: const InputDecoration(labelText: "Cijena (KM)"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Obavezno polje';
                    final parsedValue = double.tryParse(value);
                    if (parsedValue == null || parsedValue <= 0) {
                      return 'Unesite validnu cijenu';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
