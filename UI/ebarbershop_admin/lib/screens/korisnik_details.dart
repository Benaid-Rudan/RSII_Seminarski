import 'package:ebarbershop_admin/models/grad.dart';
// ignore_for_file: sort_child_properties_last

import 'package:ebarbershop_admin/models/search_result.dart';
// import 'package:ebarbershop_admin/models/uloga.dart';
import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/providers/grad_provider.dart';
import 'package:ebarbershop_admin/providers/korisnik_provider.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class KorisnikDetailsScreen extends StatefulWidget {
  Korisnik? korisnik;
  KorisnikDetailsScreen({super.key, this.korisnik});

  @override
  State<KorisnikDetailsScreen> createState() => _KorisnikDetailsScreenState();
}

class _KorisnikDetailsScreenState extends State<KorisnikDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late GradProvider _gradProvider;
  late KorisnikProvider _korisnikProvider;

  SearchResult<Grad>? gradResult;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialValue = {
      'ime': widget.korisnik?.ime,
      'prezime': widget.korisnik?.prezime,
      'email': widget.korisnik?.email,
      'username': widget.korisnik?.username,
      'password': '',
      'passwordPotvrda': '',
      'slika': widget.korisnik?.slika,
      'gradId': widget.korisnik?.gradId?.toString(),
    };

    _gradProvider = context.read<GradProvider>();
    _korisnikProvider = context.read<KorisnikProvider>();

    initForm();
  }

  Future initForm() async {
    gradResult = await _gradProvider.get();
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
                      if (widget.korisnik == null) {
                        await _korisnikProvider
                            .insert(_formKey.currentState?.value);
                      } else {
                        // await _korisnikProvider
                        //     .insert(_formKey.currentState?.value);
                        await _korisnikProvider.update(
                          widget.korisnik!.korisnikId!,
                          _formKey.currentState!.value,
                        );
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
      title: widget.korisnik?.ime ?? "Korisnik details",
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
                  name: "ime",
                  decoration: InputDecoration(labelText: "Ime"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  name: "prezime",
                  decoration: InputDecoration(labelText: "Prezime"),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "email",
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  name: "username",
                  decoration: InputDecoration(labelText: "Username"),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "password",
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  name: "passwordPotvrda",
                  decoration: InputDecoration(labelText: "Potvrdi Password"),
                  obscureText: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "slika",
                  decoration: InputDecoration(labelText: "Slika"),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown<String>(
                  name: 'gradId',
                  decoration: InputDecoration(
                    labelText: 'Grad',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['gradId']?.reset();
                      },
                    ),
                    hintText: 'Odaberi grad',
                  ),
                  items: gradResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.gradId?.toString(),
                                child: Text(item.naziv ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
