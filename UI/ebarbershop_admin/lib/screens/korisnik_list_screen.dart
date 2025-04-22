import 'dart:convert';
import 'dart:io';

import 'package:ebarbershop_admin/models/grad.dart';
import 'package:ebarbershop_admin/models/uloga.dart';
import 'package:ebarbershop_admin/providers/grad_provider.dart';
import 'package:ebarbershop_admin/providers/uloga_provider.dart';
import 'package:flutter/material.dart';
import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/providers/korisnik_provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;
  late UlogaProvider _ulogaProvider;
  SearchResult<Uloga>? ulogaResult;
  TextEditingController _ulogeController = TextEditingController();
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
  TextEditingController _ulogaControllerFilter = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      setState(() {
        _selectedImage = imageFile;
      });

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      _slikaController.text = base64Image;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korisnikProvider = context.read<KorisnikProvider>();
    _gradProvider = context.read<GradProvider>();
    _ulogaProvider = context.read<UlogaProvider>();
    _refreshData();
    _fetchGradData();
    _fetchUlogaData();
  }
  
  Future<void> _fetchUlogaData() async {
    final response = await _ulogaProvider.get();
    setState(() {
      ulogaResult = response;
    });
  }
  
  String getRoleName(Korisnik korisnik) {
    // Dodajte ispis za debugging
    print('Korisnik ${korisnik.username} uloge: ${korisnik.uloge}');
    print('Korisnik ${korisnik.username} korisnikUlogas: ${korisnik.korisnikUlogas?.map((ku) => ku.uloga?.naziv).toList()}');
    
    // First try to get roles from korisnikUlogas
    if (korisnik.korisnikUlogas != null && korisnik.korisnikUlogas!.isNotEmpty) {
      List<String> roles = korisnik.korisnikUlogas!
          .where((ku) => ku.uloga != null && ku.uloga!.naziv != null)
          .map((ku) => ku.uloga!.naziv!)
          .toList();
      
      if (roles.isNotEmpty) {
        return roles.join(', ');
      }
    }
    
    // Fallback to uloge field
    if (korisnik.uloge != null && korisnik.uloge!.isNotEmpty) {
      return korisnik.uloge!.join(', ');
    }
    
    return 'Nepoznato';
  }

  Future<void> _fetchGradData() async {
    final response = await _gradProvider.get();
    setState(() {
      gradResult = response;
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      var data = await _korisnikProvider.get(filter:  {'IsUlogeIncluded':true});
      setState(() {
        result = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
      color: Colors.blueGrey,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Ime",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _imeControllerFilter,
                onChanged: (value) {
                  _filterData();
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Prezime",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _prezimeControllerFilter,
                onChanged: (value) {
                  _filterData();
                },
              ),
            ),
            SizedBox(width: 16),
             Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Uloga",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blueGrey[100],
                  labelStyle: TextStyle(color: Colors.black),
                ),
                controller: _ulogaControllerFilter,
                onChanged: (value) {
                  _filterData();
                },
              ),
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

  Future<void> _filterData() async {
    setState(() => _isLoading = true);
    try {
      var data = await _korisnikProvider.get(
        filter: {
          'ime': _imeControllerFilter.text,
          'prezime': _prezimeControllerFilter.text,
          'IsUlogeIncluded': 'true',
          'Uloga': _ulogaControllerFilter.text,
        },
      );
      setState(() {
        result = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error filtering users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String getGradNazivById(String gradId) {
    final grad = gradResult?.result.firstWhere(
      (grad) => grad.gradId.toString() == gradId,
      orElse: () => Grad(gradId: null, naziv: 'Nepoznato'),
    );
    return grad?.naziv ?? 'Nepoznato';
  }

  Widget _buildDataListView() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              MaterialStateColor.resolveWith((states) => Colors.black),
          dataRowColor:
              MaterialStateColor.resolveWith((states) => Colors.grey[900]!),
          columns: [
            DataColumn(
                label: Text('Ime',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Prezime',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Email',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Korisničko ime',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Grad',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Slika',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Uloga',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Akcije',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: result?.result.asMap().entries.map((entry) {
                int index = entry.key;
                Korisnik e = entry.value;

                return DataRow(
                  color: MaterialStateColor.resolveWith(
                    (states) =>
                        index % 2 == 0 ? Colors.grey[850]! : Colors.grey[800]!,
                  ),
                  cells: [
                    DataCell(Text(e.ime ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(e.prezime ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(e.email ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(e.username ?? "",
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(getGradNazivById(e.gradId.toString()),
                        style: TextStyle(color: Colors.white))),
                    DataCell(
                      e.slika != null && e.slika!.isNotEmpty
                          ? (e.slika!.startsWith('http') || e.slika!.startsWith('https')
                              ? Image.network(e.slika!,
                                  width: 50, height: 50, fit: BoxFit.cover)
                              : Image.memory(base64Decode(e.slika!),
                                  width: 50, height: 50, fit: BoxFit.cover))
                          : Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    DataCell(Text(getRoleName(e),
                        style: TextStyle(color: Colors.white))),
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
                                        backgroundColor: Colors.grey[900],
                                        title: Text("Potvrdi brisanje",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        content: Text(
                                            "Želite li obrisati korisnika?",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        actions: [
                                          TextButton(
                                            child: Text("Odustani",
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Obriši",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ) ??
                                  false;

                              if (confirmDelete) {
                                await _korisnikProvider.delete(e.korisnikId!);
                                _refreshData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Korisnik uspješno obrisan'),
                                    backgroundColor: Colors.red,
                                  )
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList() ??
              [],
        ),
      ),
    );
  }

  void _showUserDialog({Korisnik? korisnik}) {
    _selectedImage = null;

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

      if (korisnik.slika != null && korisnik.slika!.isNotEmpty) {
        setState(() {
          _selectedImage = null;
        });
      }
    }

    

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(korisnik == null ? "Dodaj korisnika" : "Uredi korisnika"),
        content: Container(
          width: 400,
          height: 500,
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'ime',
                    controller: _imeController,
                    decoration: InputDecoration(labelText: "Ime"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ime je obavezno';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'prezime',
                    controller: _prezimeController,
                    decoration: InputDecoration(labelText: "Prezime"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prezime je obavezno';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'email',
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "Email"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email je obavezan';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'username',
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: "Korisničko ime"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Korisničko ime je obavezno';
                      }
                      return null;
                    },
                  ),
                  FormBuilderField(
                    name: 'slika',
                    validator: (value) {
                      // Dozvoljavamo da slika može biti prazna pri ažuriranju korisnika
                      if (_selectedImage == null &&
                          korisnik == null) {
                        return 'Slika je obavezna za novog korisnika';
                      }
                      return null;
                    },
                    builder: ((field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          label: Text('Izaberite sliku'),
                          errorText: field.errorText,
                        ),
                        child: ListTile(
                          leading: Icon(Icons.photo),
                          title: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : (korisnik?.slika != null &&
                                      korisnik!.slika!.isNotEmpty
                                  ? (korisnik!.slika!.startsWith('http') || korisnik!.slika!.startsWith('https')
                                      ? Image.network(
                                          korisnik!.slika!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.memory(
                                          base64Decode(korisnik!.slika!),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ))
                                  : Text('Nema slike')),
                          trailing: Icon(Icons.file_upload),
                          onTap: () {
                            _pickImage();
                          },
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'password',
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Lozinka",
                      hintText: korisnik != null ? "Unesite lozinku" : null,
                    ),
                    validator: (value) {
                      if (korisnik == null && (value == null || value.isEmpty)) {
                        return 'Ponovite lozinku';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'passwordPotvrda',
                    controller: _passwordPotvrdaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Potvrda lozinke",
                      hintText: korisnik != null ? "Unesite lozinku" : null,
                    ),
                    validator: (value) {
                      if (korisnik == null && (value == null || value.isEmpty)) {
                        return 'Ponovite lozinku';
                      }
                      if (_passwordController.text != value && _passwordController.text.isNotEmpty) {
                        return 'Lozinke se ne podudaraju';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  FormBuilderDropdown<String>(
                    name: 'gradId',
                    decoration: InputDecoration(labelText: "Grad"),
                    initialValue:
                        korisnik != null ? korisnik.gradId?.toString() : null,
                    items: gradResult?.result.isNotEmpty ?? false
                        ? gradResult!.result
                            .map((item) => DropdownMenuItem(
                                  value: item.gradId?.toString(),
                                  child: Text(item.naziv ?? ""),
                                ))
                            .toList()
                        : [
                            DropdownMenuItem(
                                value: "", child: Text('Nema gradova'))
                          ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Grad je obavezan';
                      }
                      return null;
                    },
                  ),

                  
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Odustani"),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                final formData = _formKey.currentState?.value;
                
                try {
                  Map<String, dynamic> userData = {
                    'Ime': formData?['ime'],
                    'Prezime': formData?['prezime'],
                    'Email': formData?['email'],
                    'Username': formData?['username'],
                    'GradId': formData?['gradId'],
                    'UlogeID': [3], 
                    'request': 'some_value',
                  };
                  
                  // Dodaj lozinku samo ako je popunjena
                  if (_passwordController.text.isNotEmpty) {
                    userData['Password'] = formData?['password'];
                    userData['PasswordPotvrda'] = formData?['passwordPotvrda'];
                  }
                  
                  // Dodaj sliku samo ako je odabrana ili već postoji
                  if (_slikaController.text.isNotEmpty) {
                    userData['Slika'] = _slikaController.text;
                  } else if (korisnik?.slika != null && korisnik!.slika!.isNotEmpty) {
                    userData['Slika'] = korisnik!.slika;
                  }

                  if (korisnik == null) {
                    // Osiguraj da lozinka postoji za novi unos
                    if (!userData.containsKey('Password')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lozinka je obavezna za novog korisnika'))
                      );
                      return;
                    }
                    
                    print('Inserting user with data: $userData');
                    await _korisnikProvider.insert(userData);
                  } else {
                    if (korisnik.korisnikId != null) {
                      print('Updating user ${korisnik.korisnikId} with data: $userData');
                      await _korisnikProvider.update(korisnik.korisnikId!, userData);
                    }
                  }

                  await _refreshData();
                  Navigator.pop(context);
                  
                  // Dodavanje povratne informacije
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(korisnik == null ? 'Korisnik uspješno dodan' : 'Korisnik uspješno ažuriran'),
                    backgroundColor: Colors.green,)
                  );
                } catch (e) {
                  print('Error saving user: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Greška: $e'))
                  );
                }
              }
            },
            child: Text("Sačuvaj"),
          ),
        ],
      ),
    );
  }
}