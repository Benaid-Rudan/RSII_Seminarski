import 'dart:convert';
import 'package:ebarbershop_mobile/main.dart';
import 'package:ebarbershop_mobile/models/grad.dart';
import 'package:ebarbershop_mobile/providers/grad_provider.dart';
import 'package:ebarbershop_mobile/providers/korisnik_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  static var routeName = "/user_profile";

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _imeController;
  late TextEditingController _prezimeController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordPotvrdaController;
  File? _selectedImage;
  int? _selectedGradId;
  List<Grad> _gradovi = [];
  bool _obscurePassword = true;
  bool _obscurePasswordPotvrda = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _imeController = TextEditingController(text: Authorization.ime);
    _prezimeController = TextEditingController(text: Authorization.prezime);
    _emailController = TextEditingController(text: Authorization.email);
    _usernameController = TextEditingController(text: Authorization.username);
    _passwordController = TextEditingController();
    _passwordPotvrdaController = TextEditingController();
    
    _selectedGradId = Authorization.gradId != null 
        ? int.tryParse(Authorization.gradId.toString()) 
        : null;
    
    _loadGradovi();
  }
  
  Future<void> _loadGradovi() async {
    final gradProvider = Provider.of<GradProvider>(context, listen: false);
    try {
      var gradoviData = await gradProvider.get();
      if (mounted) {
        setState(() {
          _gradovi = gradoviData.result.cast<Grad>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri učitavanju gradova: ${e.toString()}")),
        );
      }
    }
  }

  String get gradNaziv {
    if (_isLoading) return "Učitavanje...";
    if (_gradovi.isEmpty) return "Nepoznato";
    
    final gradId = Authorization.gradId != null 
        ? int.tryParse(Authorization.gradId.toString())
        : null;
    
    final grad = _gradovi.firstWhere(
      (g) => g.gradId == gradId,
      orElse: () => Grad(naziv: "Nepoznato"),
    );
    
    return grad.naziv ?? "Nepoznato";
  }

  bool _isPickingImage = false;
  Future<void> _pickImage() async { 
  if (_isPickingImage) return;
  
  setState(() {
    _isPickingImage = true;
  });

  try {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška pri odabiru slike: ${e.toString()}")),
    );
  } finally {
    setState(() {
      _isPickingImage = false;
    });
  }
}

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text.isNotEmpty && 
          _passwordController.text != _passwordPotvrdaController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lozinke se ne podudaraju")),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);

        String? base64Image;
        if (_selectedImage != null) {
          final bytes = await _selectedImage!.readAsBytes();
          base64Image = base64Encode(bytes);
        }

        var updatedData = {
          "korisnikId": Authorization.userId,
          "ime": _imeController.text,
          "prezime": _prezimeController.text,
          "email": _emailController.text,
          "username": _usernameController.text,
          if (_passwordController.text.isNotEmpty) "password": _passwordController.text,
          if (_passwordController.text.isNotEmpty) "passwordPotvrda": _passwordPotvrdaController.text,
          "gradId": _selectedGradId,
        };

        updatedData["slika"] = base64Image ?? Authorization.slika;

        var updatedUser = await korisnikProvider.update(Authorization.userId!, updatedData);
        
        Authorization.ime = updatedUser.ime;
        Authorization.prezime = updatedUser.prezime;
        Authorization.email = updatedUser.email;
        Authorization.username = updatedUser.username;
        Authorization.gradId = updatedUser.gradId?.toString();
        Authorization.slika = updatedUser.slika;  
        Authorization.localImage = null;  
        setState(() {
        _isSaving=false;
      });
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil uspješno ažuriran"),
            backgroundColor: Colors.green,),
          );
          Navigator.of(context).pop();
          setState(() {
            _isSaving = false;
            _selectedImage = null; 
          });
        }
      } catch (e) {
        if(mounted){
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Greška pri ažuriranju: ${e.toString()}")),
          );
        }
      }
    }
  }

  ImageProvider? _getProfileImage() {
  if (Authorization.slika != null && Authorization.slika!.isNotEmpty) {
    try {
      if (Authorization.slika!.startsWith('http')) {
        return CachedNetworkImageProvider(Authorization.slika!);
      }
      
      final String imageString = Authorization.slika!;
      final String base64String = imageString.startsWith('data:image')
          ? imageString.split(',').last
          : imageString;
          
      final bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      print('Greška pri učitavanju slike: $e');
      return null;
    }
  }
  
  if (Authorization.localImage != null) {
    return FileImage(File(Authorization.localImage!));
  }
  
  return null;
}
  @override
  Widget build(BuildContext context) {
    print('Trenutna slika u Authorization: ${Authorization.slika}');
  print('Trenutna lokalna slika: ${Authorization.localImage}');
  print('Odabrana slika: $_selectedImage');
    final userData = {
      "ime": Authorization.ime,
      "prezime": Authorization.prezime,
      "email": Authorization.email,
      "username": Authorization.username,
      "slika": Authorization.slika,
      "gradId": Authorization.gradId,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Korisnički profil"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isSaving ? null : _showEditDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _getProfileImage(),
                    child: _getProfileImage() == null 
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${userData["ime"]} ${userData["prezime"]}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "@${userData["username"]}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text("Ime i prezime"),
                            subtitle:
                                Text("${userData["ime"] ?? ""} ${userData["prezime"] ?? ""}".trim()),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text("Email"),
                            subtitle: Text(userData["email"] as String? ?? ""),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.location_city),
                            title: const Text("Grad"),
                            subtitle: Text(gradNaziv),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showEditDialog() {
  File? dialogImage;
  final String? originalImage = Authorization.slika;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Uredi profil"),
            content: _isSaving
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (_isSaving) return;
                              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setDialogState(() {
                                  dialogImage = File(pickedFile.path);
                                });
                              }
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: dialogImage != null
                                      ? FileImage(dialogImage!)
                                      : Authorization.slika != null
                                          ? _getNetworkImageProvider(Authorization.slika!)
                                          : null,
                                  child: dialogImage == null && 
                                        Authorization.slika == null
                                      ? const Icon(Icons.person, size: 50)
                                      : null,
                                ),
                                if (_isPickingImage)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black54,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () async {
                              if (_isSaving) return;
                              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setDialogState(() {
                                  dialogImage = File(pickedFile.path);
                                });
                              }
                            },
                            child: const Text("Promijeni sliku"),
                          ),
                          TextFormField(
                            controller: _imeController,
                            decoration: const InputDecoration(labelText: "Ime"),
                            validator: (value) =>
                                value!.isEmpty ? 'Unesite ime' : null,
                            enabled: !_isSaving,
                          ),
                          TextFormField(
                            controller: _prezimeController,
                            decoration: const InputDecoration(labelText: "Prezime"),
                            validator: (value) =>
                                value!.isEmpty ? 'Unesite prezime' : null,
                            enabled: !_isSaving,
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: "Email"),
                            validator: (value) =>
                                value!.isEmpty ? 'Unesite email' : null,
                            enabled: !_isSaving,
                          ),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(labelText: "Username"),
                            validator: (value) =>
                                value!.isEmpty ? 'Unesite username' : null,
                            enabled: !_isSaving,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: "Nova lozinka",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: _isSaving
                                    ? null
                                    : () {
                                        setDialogState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            enabled: !_isSaving,
                          ),
                          TextFormField(
                            controller: _passwordPotvrdaController,
                            decoration: InputDecoration(
                              labelText: "Potvrdi lozinku",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePasswordPotvrda ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: _isSaving
                                    ? null
                                    : () {
                                        setDialogState(() {
                                          _obscurePasswordPotvrda = !_obscurePasswordPotvrda;
                                        });
                                      },
                              ),
                            ),
                            obscureText: _obscurePasswordPotvrda,
                            enabled: !_isSaving,
                          ),
                          DropdownButtonFormField<int>(
                            value: _selectedGradId,
                            decoration: const InputDecoration(labelText: "Grad"),
                            items: _gradovi.map<DropdownMenuItem<int>>((grad) {
                              return DropdownMenuItem<int>(
                                value: grad.gradId,
                                child: Text(grad.naziv ?? ""),
                              );
                            }).toList(),
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    setDialogState(() {
                                      _selectedGradId = value;
                                    });
                                  },
                            validator: (value) => value == null ? 'Odaberite grad' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
            actions: <Widget>[
              if (!_isSaving) ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Odustani"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _selectedImage = dialogImage;
                    await _updateProfile();
                    if (mounted) {
                      setState(() {});
                    }
                    
                  },
                  child: const Text("Spremi"),
                ),
              ],
            ],
          );
        },
      );
    },
  ).then((_) {
    if (mounted) {
      setState(() {});
    }
  });
}
  ImageProvider? _getNetworkImageProvider(String imageUrl) {
  if (imageUrl.startsWith('http')) {
    return CachedNetworkImageProvider(imageUrl);
  } else if (imageUrl.startsWith('data:image')) {
    try {
      final bytes = base64Decode(imageUrl.split(',').last);
      return MemoryImage(bytes);
    } catch (e) {
      print('Greška pri dekodiranju base64 slike: $e');
      return null;
    }
  }
  return null;
}
}