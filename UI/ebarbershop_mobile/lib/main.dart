import 'package:ebarbershop_mobile/models/grad.dart';
import 'package:ebarbershop_mobile/screens/cart_screen.dart';
import 'package:ebarbershop_mobile/screens/home_screen.dart';
import 'package:ebarbershop_mobile/screens/product_details.dart';
import 'package:ebarbershop_mobile/screens/product_list_screen.dart';
import 'package:ebarbershop_mobile/screens/user_profile_screen.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:ebarbershop_mobile/widgets/master_screen.dart';
import 'package:ebarbershop_mobile/providers/cart_provider.dart';
import 'package:ebarbershop_mobile/providers/grad_provider.dart';
import 'package:ebarbershop_mobile/providers/korisnik_provider.dart';
import 'package:ebarbershop_mobile/providers/narudzba_provider.dart';
import 'package:ebarbershop_mobile/providers/novost_provider.dart';
import 'package:ebarbershop_mobile/providers/product_provider.dart';
import 'package:ebarbershop_mobile/providers/rezervacija_provider.dart';
import 'package:ebarbershop_mobile/providers/termin_provider.dart';
import 'package:ebarbershop_mobile/providers/usluga_provider.dart';
import 'package:ebarbershop_mobile/providers/vrsta_proizvoda.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => VrstaProizvodaProvider()),
      ChangeNotifierProvider(create: (_) => KorisnikProvider()),
      ChangeNotifierProvider(create: (_) => GradProvider()),
      ChangeNotifierProvider(create: (_) => RezervacijaProvider()),
      ChangeNotifierProvider(create: (_) => UslugaProvider()),
      ChangeNotifierProvider(create: (_) => NovostProvider()),
      ChangeNotifierProvider(create: (_) => TerminProvider()),
      ChangeNotifierProvider(create: (_) => NarudzbaProvider()),
    ],
    child: const MyMaterialApp(),
  ));
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RS II Material app',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.blueGrey, // Crna pozadina
        primaryColor: Colors.white,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey[700]!,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900], // Tamna pozadina polja
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIconColor: Colors.white, // Boja ikonica u poljima
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
      home: LoginPage(),
      routes: {
        CartScreen.routeName: (context) => CartScreen(),
        ProductListScreen.routeName: (context) => ProductListScreen(),
        RegistrationPage.routeName: (context) => RegistrationPage(),
        UserProfileScreen.routeName: (context) => UserProfileScreen(),

      },
      // Define dynamic route for product details
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/product_details/') ?? false) {
          final productId  = settings.name?.split('/')[2]; // Extract product ID
          return MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(proizvodId: productId!),
          );
        }
        return null; // Return null if no matching route
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  late KorisnikProvider _korisnikProvider;

  @override
  Widget build(BuildContext context) {
    _korisnikProvider = context.read<KorisnikProvider>();
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400, maxHeight: 400),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cut,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Username",
                        prefixIcon: Icon(Icons.email, color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(color: Colors.white),
                      controller: _usernameController,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.password, color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(color: Colors.white),
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        var username = _usernameController.text.trim();
                        var password = _passwordController.text.trim();

                        if (username.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Molimo unesite ispravan username i password."),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return; 
                        }

                         try {
                           var korisnici = await _korisnikProvider.get(filter: {
                             'username': username,
                           });

                           if (korisnici.result.isEmpty) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text("Korisnik nije pronađen."),
                                 backgroundColor: Colors.red,
                               ),
                             );
                             return;
                           }
                            var korisnik = korisnici.result.first;
                            print('Dobijeni korisnik sa servera: ${korisnik.toJson()}'); 
                            Authorization.username = username;
                            Authorization.password = password;
                            Authorization.userId = korisnik.korisnikId;
                            Authorization.ime = korisnik.ime;
                            Authorization.prezime = korisnik.prezime;
                            Authorization.email = korisnik.email;
                             Authorization.gradId = korisnik.gradId?.toString();
                            Authorization.slika = korisnik.slika;
                            Authorization.localImage = null;
                             print('Spremljena slika: ${Authorization.slika}');

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MasterScreenWidget(
                                 child: HomeScreen(),
                              ),
                            ),
                          );
                         } on Exception catch (e) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                               content:
                                   Text("Neuspješna prijava: ${e.toString()}"),
                               backgroundColor: Colors.red,
                             ),
                           );
                         }
                      },
                      child: Text("Login"),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RegistrationPage(),
                          ),
                        );
                      },
                      child: Text("Nemate račun? Registrujte se"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  static var routeName = "/registration";

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController _imeController = TextEditingController();
  TextEditingController _prezimeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordPotvrdaController = TextEditingController();
  int? _selectedGradId;
  late GradProvider _gradProvider;
  List<Grad> _gradovi = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gradProvider = context.read<GradProvider>();
    _fetchGradovi();
  }

  Future<void> _fetchGradovi() async {
    var gradoviData = await _gradProvider.get();
    setState(() {
      _gradovi = gradoviData.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("Registracija")),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400, maxHeight: 800),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cut,
                        size: 100,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Ime",
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.white),
                        controller: _imeController,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Prezime",
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.white),
                        controller: _prezimeController,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email, color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.white),
                        controller: _emailController,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.white),
                        controller: _usernameController,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.password, color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.white),
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Potvrdi Password",
                          prefixIcon: Icon(Icons.password, color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.white),
                        controller: _passwordPotvrdaController,
                        obscureText: true,
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: "Grad",
                          prefixIcon: Icon(Icons.location_city, color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedGradId,
                        items: _gradovi.map((Grad grad) {
                          return DropdownMenuItem<int>(
                            value: grad.gradId,
                            child: Text(grad.naziv ?? "", style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedGradId = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_passwordController.text != _passwordPotvrdaController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Lozinke se ne podudaraju."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                
                          var korisnik = {
                            "ime": _imeController.text,
                            "prezime": _prezimeController.text,
                            "email": _emailController.text,
                            "username": _usernameController.text,
                            "password": _passwordController.text,
                            "passwordPotvrda": _passwordPotvrdaController.text,
                            "slika": "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png",
                            "gradId": _selectedGradId,
                            "ulogeID": [3],
                          };
                
                          try {
                            var korisnikProvider = context.read<KorisnikProvider>();
                            await korisnikProvider.insert(korisnik);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Uspešno ste se registrovali."),
                                backgroundColor: Colors.green,
                              ),
                            );
                
                            // Navigacija natrag na Login page
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Došlo je do greške: ${e.toString()}"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text("Registrujte se"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
