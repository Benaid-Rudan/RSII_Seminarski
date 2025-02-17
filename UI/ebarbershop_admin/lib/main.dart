import 'package:ebarbershop_admin/providers/grad_provider.dart';
import 'package:ebarbershop_admin/providers/korisnik_provider.dart';
import 'package:ebarbershop_admin/providers/novost_provider.dart';
import 'package:ebarbershop_admin/providers/product_provider.dart';
import 'package:ebarbershop_admin/providers/rezervacija_provider.dart';
import 'package:ebarbershop_admin/providers/usluga_provider.dart';
import 'package:ebarbershop_admin/providers/vrsta_proizvoda.dart';
import 'package:ebarbershop_admin/screens/product_list_screen.dart';
import 'package:ebarbershop_admin/utils/util.dart';
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
    ],
    child: const MyMaterialApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        primarySwatch: Colors.blue,
      ),
      home: LayoutExamples(),
    );
  }
}

class MyAppBar extends StatelessWidget {
  String title;
  MyAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;
  void incrementCounter() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('You have pushed $_count times'),
        ElevatedButton(onPressed: incrementCounter, child: Text("Increment++")),
      ],
    );
  }
}

class LayoutExamples extends StatelessWidget {
  const LayoutExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 150,
          color: Colors.red,
          child: Center(
            child: Container(
              height: 100,
              color: Colors.blue,
              child: Text("Example text"),
              alignment: Alignment.center,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [Text("Item1"), Text("Item2"), Text("Item3")],
        ),
        Container(
          height: 150,
          color: Colors.red,
          child: Text("Container 2"),
          alignment: Alignment.center,
        )
      ],
    );
  }
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RS II Material app',
      // theme: ThemeData(primarySwatch: Colors.blue),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.blue),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  late ProductProvider _productProvider;

  @override
  Widget build(BuildContext context) {
    _productProvider = context.read<ProductProvider>();
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Image.network(
                  //   "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsCf_sywD508Bnnq-s_hC35LrhMaBNM3jfrA&s",
                  // height: 100,
                  // width: 100,
                  // ),
                  Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                    width: 100,
                  ),

                  TextField(
                      decoration: InputDecoration(
                          labelText: "Username", prefixIcon: Icon(Icons.email)),
                      controller: _usernameController),
                  SizedBox(
                    height: 8,
                  ),
                  TextField(
                      decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.password)),
                      controller: _passwordController),
                  ElevatedButton(
                      onPressed: () async {
                        var username = _usernameController.text;
                        var password = _passwordController.text;
                        print("Login proceed $username $password");

                        Authorization.username = username;
                        Authorization.password = password;

                        try {
                          await _productProvider.get();

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ProductListScreen(),
                          ));
                        } on Exception catch (e) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Text("Error"),
                                    content: Text(e.toString()),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("OK"))
                                    ],
                                  ));
                        }
                      },
                      child: Text("Login"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
