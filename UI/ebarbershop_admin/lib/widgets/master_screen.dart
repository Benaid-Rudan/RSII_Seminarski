import 'package:ebarbershop_admin/main.dart';
import 'package:ebarbershop_admin/models/korisnik.dart';
import 'package:ebarbershop_admin/screens/novost_list_screen.dart';
import 'package:ebarbershop_admin/screens/product_details.dart';
import 'package:ebarbershop_admin/screens/product_list_screen.dart';
import 'package:ebarbershop_admin/screens/korisnik_list_screen.dart';
import 'package:ebarbershop_admin/screens/rezervacija_details.dart';
import 'package:ebarbershop_admin/screens/rezervacija_list_screen.dart';

import 'package:flutter/material.dart';

class MasterScreenWidget extends StatefulWidget {
  Widget? child;
  String? title;
  Widget? title_widget;
  MasterScreenWidget({this.child, this.title, this.title_widget, super.key});

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title_widget ?? Text(widget.title ?? ""),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("Login page"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Zaposlenici"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => KorisnikListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Proizvodi"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProductListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Detalji"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(),
                ));
              },
            ),
            ListTile(
              title: Text("Rezervacije"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RezervacijaListScreen(),
                ));
              },
            ),
            ListTile(
              title: Text("Novosti"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NovostListScreen(),
                ));
              },
            )
          ],
        ),
      ),
      body: widget.child!,
    );
  }
}
