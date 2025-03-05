import 'package:ebarbershop_admin/models/grad.dart';
import 'package:ebarbershop_admin/providers/grad_provider.dart';
import 'package:flutter/material.dart';
import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/korisnik_provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class KorisnikListScreen extends StatefulWidget {
  const KorisnikListScreen({super.key});

  @override
  State<KorisnikListScreen> createState() => _KorisnikListScreenState();
}

class _KorisnikListScreenState extends State<KorisnikListScreen> {
  late KorisnikProvider _korisnikProvider;
  SearchResult<Korisnik>? result;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormBuilderState>();
  SearchResult<Grad>? gradResult;
  late GradProvider _gradProvider;

  TextEditingController _imeControllerFilter = TextEditingController();
  TextEditingController _prezimeControllerFilter = TextEditingController();
  TextEditingController _imeController = TextEditingController();
  TextEditingController _prezimeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _slikaController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordPotvrdaController = TextEditingController();
  TextEditingController _gradController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korisnikProvider = context.read<KorisnikProvider>();
    _gradProvider = context.read<GradProvider>();
    _refreshData();
    _fetchGradData();
  }

  Future<void> _fetchGradData() async {
    final response = await _gradProvider.get();
    print('API Response: ${response.toString()}');
    gradResult = response;
    setState(() {});
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    var data = await _korisnikProvider.get();
    setState(() {
      result = data;
      _isLoading = false;
    });
    _imeController.clear();
    _prezimeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearch(),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : _buildDataListView(),
      ],
    );
  }

  Widget _buildSearch() {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Ime",
                  border: OutlineInputBorder(),
                ),
                controller: _imeControllerFilter,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Prezime",
                  border: OutlineInputBorder(),
                ),
                controller: _prezimeControllerFilter,
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                var data = await _korisnikProvider.get(filter: {
                  'ime': _imeControllerFilter.text,
                  'prezime': _prezimeControllerFilter.text
                });
                setState(() {
                  result = data;
                  _isLoading = false;
                });
              },
              child: Text("Pretraga"),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _showUserDialog();
              },
              child: Text("Dodaj"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
                label:
                    Text('Ime', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Prezime',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Email',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Korisničko ime',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Slika',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Akcije',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: result?.result
                  .map((Korisnik e) => DataRow(cells: [
                        DataCell(Text(e.ime ?? "")),
                        DataCell(Text(e.prezime ?? "")),
                        DataCell(Text(e.email ?? "")),
                        DataCell(Text(e.username ?? "")),
                        DataCell(
                          e.slika != null && e.slika!.isNotEmpty
                              ? Image.network(e.slika!,
                                  width: 50, height: 50, fit: BoxFit.cover)
                              : Icon(Icons.person, size: 50),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showUserDialog(korisnik: e),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool confirmDelete = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Potvrdi brisanje"),
                                            content: Text(
                                                "Želite li obrisati korisnika?"),
                                            actions: [
                                              TextButton(
                                                child: Text("Odustani"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      false); // Vrati false
                                                },
                                              ),
                                              TextButton(
                                                child: Text("Obriši"),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true); // Vrati true
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.red, // Boja teksta
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ) ??
                                      false;

                                  if (confirmDelete) {
                                    await _korisnikProvider
                                        .delete(e.korisnikId!);
                                    _refreshData();
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      ]))
                  .toList() ??
              [],
        ),
      ),
    );
  }

  void _showUserDialog({Korisnik? korisnik}) {
    _imeController.clear();
    _prezimeController.clear();
    _emailController.clear();
    _usernameController.clear();
    _slikaController.clear();
    _passwordController.clear();
    _passwordPotvrdaController.clear();
    _gradController.clear();

    if (korisnik != null) {
      _imeController.text = korisnik.ime ?? "";
      _prezimeController.text = korisnik.prezime ?? "";
      _emailController.text = korisnik.email ?? "";
      _usernameController.text = korisnik.username ?? "";
      _slikaController.text = korisnik.slika ?? "";
      _gradController.text = korisnik.gradId.toString() ?? "";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(korisnik == null ? "Dodaj korisnika" : "Uredi korisnika"),
        content: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'ime',
                controller: _imeController,
                decoration: InputDecoration(labelText: "Ime"),
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'prezime',
                controller: _prezimeController,
                decoration: InputDecoration(labelText: "Prezime"),
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'email',
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'username',
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Korisničko ime"),
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'slika',
                controller: _slikaController,
                decoration: InputDecoration(labelText: "URL slike"),
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'password',
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Lozinka"),
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'passwordPotvrda',
                controller: _passwordPotvrdaController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Potvrda lozinke"),
              ),
              SizedBox(height: 10),
              FormBuilderDropdown<String>(
                name: 'gradId',
                decoration: InputDecoration(labelText: "Grad"),
                items: gradResult?.result.isNotEmpty ?? false
                    ? gradResult!.result
                        .map((item) => DropdownMenuItem(
                              value: item.gradId?.toString(),
                              child: Text(item.naziv ?? ""),
                            ))
                        .toList()
                    : [
                        DropdownMenuItem(value: "", child: Text('Nema gradova'))
                      ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                final formData = _formKey.currentState?.value;

                if (korisnik == null) {
                  // Insert new user
                  await _korisnikProvider.insert({
                    'Ime': formData?['ime'],
                    'Prezime': formData?['prezime'],
                    'Email': formData?['email'],
                    'Username': formData?['username'],
                    'Password': formData?['password'],
                    'PasswordPotvrda': formData?['passwordPotvrda'],
                    'Slika': formData?['slika'],
                    'GradId': formData?['gradId'],
                    'request': 'some_value',
                  });
                } else {
                  // Update existing user
                  if (korisnik.korisnikId != null) {
                    await _korisnikProvider.update(
                      korisnik.korisnikId!,
                      {
                        'Ime': formData?['ime'],
                        'Prezime': formData?['prezime'],
                        'Email': formData?['email'],
                        'Username': formData?['username'],
                        'Password': formData?['password'],
                        'PasswordPotvrda': formData?['passwordPotvrda'],
                        'Slika': formData?['slika'],
                        'GradId': _gradController.text.isNotEmpty
                            ? int.tryParse(_gradController.text)
                            : null
                      },
                    );
                  }
                }

                await _refreshData();

                Navigator.pop(context);
              }
            },
            child: Text("Sačuvaj"),
          ),
        ],
      ),
    );
  }
}
