import 'package:flutter/material.dart';
import 'package:ebarbershop_admin/screens/arhiv.dart';
import 'package:ebarbershop_admin/screens/usluga_list_screen.dart';
import 'package:ebarbershop_admin/screens/narudzba_list_screen.dart';
import 'package:ebarbershop_admin/screens/novost_list_screen.dart';
import 'package:ebarbershop_admin/screens/product_details.dart';
import 'package:ebarbershop_admin/screens/product_list_screen.dart';
import 'package:ebarbershop_admin/screens/korisnik_list_screen.dart';
import 'package:ebarbershop_admin/screens/rezervacija_list_screen.dart';
import 'package:ebarbershop_admin/screens/termin_list_screen.dart';

class MasterScreenWidget extends StatefulWidget {
  final Widget? child;
  final String? title;
  final Widget? title_widget;

  const MasterScreenWidget(
      {this.child, this.title, this.title_widget, super.key});

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.blueGrey[900],
            child: Column(
              children: [
                const SizedBox(height: 50),
                menuItem("Zaposlenici", KorisnikListScreen()),
                menuItem("Proizvodi", ProductListScreen()),
                menuItem("Rezervacije", RezervacijaListScreen()),
                menuItem("Novosti", NovostListScreen()),
                menuItem("Termini", TerminListScreen()),
                menuItem("Narudžbe", NarudzbaListScreen()),
                menuItem("Usluge", UslugaListScreen()),
                menuItem("Arhiva", ArhivaListScreen()),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: widget.title_widget ?? Text(widget.title ?? ""),
                  backgroundColor: Colors.blueGrey,
                ),
                Expanded(child: widget.child ?? Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget menuItem(String title, Widget screen) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MasterScreenWidget(
              title: title,
              child: screen,
            ),
          ),
        );
      },
    );
  }
}
