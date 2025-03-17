import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:ebarbershop_admin/models/narudzba.dart';
import 'package:ebarbershop_admin/models/product.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/narudzba_provider.dart';
import 'package:ebarbershop_admin/providers/product_provider.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';

class NarudzbaDetailsScreen extends StatefulWidget {
  Narudzba? narudzba;
  NarudzbaDetailsScreen({super.key, this.narudzba});

  @override
  State<NarudzbaDetailsScreen> createState() => _NarudzbaDetailsScreenState();
}

class _NarudzbaDetailsScreenState extends State<NarudzbaDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initalValue = {};
  late ProductProvider _productProvider;
  late NarudzbaProvider _narudzbaProvider;

  SearchResult<Product>? productResult;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initalValue = {
      'datum': widget.narudzba?.datum != null
          ? DateTime.parse(widget.narudzba!.datum!.toString())
          : null,
      'proizvodId': widget.narudzba?.narudzbaProizvodis?.isNotEmpty == true
          ? widget.narudzba?.narudzbaProizvodis?.first.proizvodId.toString()
          : null,
      'kupacId': widget.narudzba?.korisnikId?.toString(),
      'kolicina': widget.narudzba?.narudzbaProizvodis?.isNotEmpty == true
          ? widget.narudzba?.narudzbaProizvodis?.first.kolicina.toString()
          : null,
      'cijena': null, 
      'ukupnaCijena': null, 
    };

    _productProvider = context.read<ProductProvider>();
    _narudzbaProvider = context.read<NarudzbaProvider>();

    initForm();
  }

  Future initForm() async {
    productResult = await _productProvider.get();
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
          _buildButtons(),
        ],
      ),
      title: this.widget.narudzba?.narudzbaId != null
          ? "Narudzba ${widget.narudzba?.narudzbaId}"
          : "Nova narudzba",
    );
  }

  Widget _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initalValue,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown<String>(
                  name: 'proizvodId',
                  decoration: InputDecoration(
                    labelText: 'Proizvod',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['proizvodId']?.reset();
                        _formKey.currentState!.fields['cijena']?.didChange("");
                        _formKey.currentState!.fields['ukupnaCijena']
                            ?.didChange("");
                      },
                    ),
                    hintText: 'Odaberite proizvod',
                  ),
                  items: productResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.proizvodId?.toString(),
                                child: Text(item.naziv ?? ""),
                              ))
                          .toList() ??
                      [],
                  onChanged: (value) {
                    var selectedProduct = productResult?.result.firstWhere(
                      (p) => p.proizvodId.toString() == value,
                      orElse: () => Product(
                          0, 
                          '', 
                          '', 
                          0.0, 
                          '',
                          0, 
                          0 
                          ),
                    );

                    double cijena = selectedProduct?.cijena ?? 0;
                    _formKey.currentState!.fields['cijena']
                        ?.didChange(cijena.toString());

                    String? kolicina =
                        _formKey.currentState!.fields['kolicina']?.value;
                    _updateUkupnaCijena(cijena, kolicina);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "kupacId",
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Kupac ID"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  name: "cijena",
                  enabled: false, 
                  decoration: InputDecoration(labelText: "Cijena"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  name: "kolicina",
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Količina"),
                  onChanged: (value) {
                    String? proizvodId =
                        _formKey.currentState!.fields['proizvodId']?.value;
                    var selectedProduct = productResult?.result.firstWhere(
                        (p) => p.proizvodId.toString() == proizvodId,
                        orElse: () => Product(
                            0, 
                            '', 
                            '', 
                            0.0,
                            '', 
                            0, 
                            0 
                            ));

                    double cijena = selectedProduct?.cijena ?? 0;
                    _updateUkupnaCijena(cijena, value);
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: FormBuilderDateTimePicker(
                  name: "datum",
                  initialValue: widget.narudzba?.datum != null
                      ? DateTime.parse(widget.narudzba!.datum!.toString())
                      : DateTime.now(),
                  decoration: InputDecoration(labelText: "Datum"),
                  inputType: InputType.both,
                  format: DateFormat("yyyy-MM-dd HH:mm"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          _formKey.currentState?.saveAndValidate();
          print(_formKey.currentState?.value);

          try {
            final formData =
                Map<String, dynamic>.from(_formKey.currentState!.value);

            double ukupnaCijena = double.parse(formData['ukupnaCijena'] ?? "0");

            List<Map<String, dynamic>> listaProizvoda = [
              {
                "proizvodID": int.parse(formData['proizvodId']),
                "kolicina": int.parse(formData['kolicina']),
              }
            ];

            Map<String, dynamic> requestData = {
              "datum": (formData['datum'] as DateTime).toIso8601String(),
              "ukupnaCijena": ukupnaCijena,
              "korisnikId": int.parse(formData['kupacId']),
              "listaProizvoda": listaProizvoda,
            };

            print(requestData);

            if (widget.narudzba == null) {
              await _narudzbaProvider.insert(requestData);
            } else {
              if (widget.narudzba!.narudzbaId != null) {
                await _narudzbaProvider.update(
                  widget.narudzba!.narudzbaId!,
                  requestData,
                );
              }
            }
          } catch (e) {
            print("Greška: $e");
          }
        },
        child: Text("Sačuvaj"),
      ),
    );
  }

  void _updateUkupnaCijena(double cijena, String? kolicina) {
    int kol = int.tryParse(kolicina ?? "0") ?? 0;
    double ukupna = cijena * kol;
    _formKey.currentState!.fields['ukupnaCijena']?.didChange(ukupna.toString());
  }
}
