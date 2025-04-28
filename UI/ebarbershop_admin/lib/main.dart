import 'package:ebarbershop_admin/models/narudzba.dart';
import 'package:ebarbershop_admin/providers/grad_provider.dart';
import 'package:ebarbershop_admin/providers/korisnik_provider.dart';
import 'package:ebarbershop_admin/providers/narudzba_provider.dart';
import 'package:ebarbershop_admin/providers/novost_provider.dart';
import 'package:ebarbershop_admin/providers/product_provider.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart';
import 'package:ebarbershop_admin/providers/termin_provider.dart';
import 'package:ebarbershop_admin/providers/uloga_provider.dart';
import 'package:ebarbershop_admin/providers/usluga_provider.dart';
import 'package:ebarbershop_admin/providers/vrsta_proizvoda.dart';
import 'package:ebarbershop_admin/screens/korisnik_list_screen.dart';
import 'package:ebarbershop_admin/screens/product_list_screen.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => VrstaProizvodaProvider()),
      ChangeNotifierProvider(create: (_) => KorisnikProvider()),
      ChangeNotifierProvider(create: (_) => GradProvider()),
      ChangeNotifierProvider(create: (_) => RezervacijaProvider()),
      ChangeNotifierProvider(create: (_) => UslugaProvider()),
      ChangeNotifierProvider(create: (_) => NovostProvider()),
      ChangeNotifierProvider(create: (_) => TerminProvider()),
      ChangeNotifierProvider(create: (_) => NarudzbaProvider()),
      ChangeNotifierProvider(create: (_) => UlogaProvider()),
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
                          return; // Zaustavi daljnje izvršavanje
                        }

                        print("Login proceed $username $password");

                        Authorization.username = username;
                        Authorization.password = password;

                        try {
                          // Dohvati podatke o korisniku
                          var korisnik = await _korisnikProvider.authenticate(username, password);

                          // Provjeri ima li korisnik ulogu "Administrator" ili "Uposlenik"
                          bool isAuthorized = false;
                          
                          if (korisnik.uloge != null && korisnik.uloge!.isNotEmpty) {
                            // Store user roles in Authorization class
                            Authorization.roles = korisnik.uloge;
                            isAuthorized = korisnik.uloge!.contains("Administrator") || 
                                          korisnik.uloge!.contains("Uposlenik");
                          }

                          if (!isAuthorized) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Samo korisnici s ulogom Administrator ili Uposlenik mogu se prijaviti."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Ako je korisnik administrator ili uposlenik, preusmjeri na MasterScreen
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MasterScreenWidget(
                                title: "Proizvodi",
                                child: ProductListScreen(),
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
