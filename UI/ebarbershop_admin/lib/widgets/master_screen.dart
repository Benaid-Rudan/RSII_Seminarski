import 'package:ebarbershop_admin/main.dart';
import 'package:ebarbershop_admin/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:ebarbershop_admin/screens/arhiv.dart';
import 'package:ebarbershop_admin/screens/usluga_list_screen.dart';
import 'package:ebarbershop_admin/screens/narudzba_list_screen.dart';
import 'package:ebarbershop_admin/screens/novost_list_screen.dart';
import 'package:ebarbershop_admin/screens/product_list_screen.dart';
import 'package:ebarbershop_admin/screens/korisnik_list_screen.dart';
import 'package:ebarbershop_admin/screens/rezervacija_list_screen.dart';
import 'package:ebarbershop_admin/screens/termin_list_screen.dart';

class MasterScreenWidget extends StatefulWidget {
  final Widget? child;
  final String? title;
  final Widget? title_widget;

  const MasterScreenWidget({
    this.child,
    this.title,
    this.title_widget,
    super.key,
  });

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  @override
  Widget build(BuildContext context) {
    String username = Authorization.username ?? "Guest";
    return Scaffold(
      body: Row(
        children: [
          Container(
  width: 250,
  color: Colors.blueGrey[900],
  child: SafeArea(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.cut, size: 50, color: Colors.white),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Hello, $username",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 20),
              menuItem("Zaposlenici", Icons.people, KorisnikListScreen()),
              menuItem("Proizvodi", Icons.shopping_bag, ProductListScreen()),
              menuItem("Rezervacije", Icons.calendar_today, RezervacijaListScreen()),
              menuItem("Novosti", Icons.article, NovostListScreen()),
              menuItem("Termini", Icons.schedule, TerminListScreen()),
              menuItem("Narudžbe", Icons.shopping_cart, NarudzbaListScreen()),
              menuItem("Usluge", Icons.design_services, UslugaListScreen()),
              menuItem("Arhiva", Icons.archive, ArhivaListScreen()),
              const SizedBox(height: 30),
              const Divider(color: Colors.white54),
            ],
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.white),
        title: const Text("Odjava", style: TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
      ),
      const SizedBox(height: 10),
    ],
  ),
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

  Widget menuItem(String title, IconData icon, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
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
