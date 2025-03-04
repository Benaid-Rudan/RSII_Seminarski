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
          // FIXIRANI MENI SA STRANE
          Container(
            width: 250, // Fiksna širina menija
            color: Colors.blueGrey[900], // Boja menija
            child: Column(
              children: [
                const SizedBox(height: 50), // Prostor na vrhu
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

          // GLAVNI SADRŽAJ
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: widget.title_widget ?? Text(widget.title ?? ""),
                  backgroundColor: Colors.blueGrey,
                  leading: Navigator.canPop(context)
                      ? IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      : null, // Strelica za nazad samo ako postoji prethodni ekran
                ),
                Expanded(child: widget.child ?? Container()), // Sadržaj ekrana
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
        Navigator.of(context).pushReplacement(
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
