import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebarbershop_mobile/main.dart';
import 'package:ebarbershop_mobile/providers/korisnik_provider.dart';
import 'package:ebarbershop_mobile/screens/appointment_list_screen.dart';
import 'package:ebarbershop_mobile/screens/cart_screen.dart';
import 'package:ebarbershop_mobile/screens/employee_selection_screen.dart';
import 'package:ebarbershop_mobile/screens/home_screen.dart';
import 'package:ebarbershop_mobile/screens/product_list_screen.dart';
import 'package:ebarbershop_mobile/screens/reviews_screen.dart';
import 'package:ebarbershop_mobile/screens/user_profile_screen.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class MasterScreenWidget extends StatefulWidget {
  Widget? child;
  final String? title;
  MasterScreenWidget({this.child, this.title, Key? key}) : super(key: key);

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  int currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
      if (currentIndex == 0) {
        widget.child = HomeScreen();
      }
      else if (currentIndex == 1) {
        widget.child = ProductListScreen();
      }
      else if (currentIndex == 2) {
        widget.child = ChangeNotifierProvider(
          create: (context) => KorisnikProvider(),
          child: EmployeeSelectionScreen(),
        );
      }
      else if (currentIndex == 3) {
        widget.child = ReviewsScreen();
      }
      else if (currentIndex == 4) {
        widget.child = UserProfileScreen();
      }
      else if (currentIndex == 5) {
        widget.child = AppointmentListScreen();
      }
    });
  }

  ImageProvider? _getUserProfileImage() {
    if (Authorization.slika == null || Authorization.slika!.isEmpty) {
      return null;
    }

    try {
      if (Authorization.slika!.startsWith('http')) {
        return CachedNetworkImageProvider(Authorization.slika!);
      }
      
      if (Authorization.slika!.startsWith('/') || 
          Authorization.slika!.startsWith('data:image')) {
        final String base64String = Authorization.slika!.startsWith('data:image')
            ? Authorization.slika!.split(',').last
            : Authorization.slika!;
            
        final bytes = base64Decode(base64String);
        if (bytes.isEmpty) throw Exception('Empty bytes after decoding');
        return MemoryImage(bytes);
      }
      
      if (Authorization.localImage != null) {
        return FileImage(File(Authorization.localImage!));
      }
    } catch (e) {
      print('Error loading profile image: $e');
      return null;
    }
    
    return null;
  }

  Future<void> _handleLogout() async {
    try {
      Authorization.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Došlo je do greške prilikom odjave')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("eBarbershop"),
        actions: [
          if (Authorization.username != null)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  await _handleLogout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Text("Odjava"),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Text(Authorization.username ?? ''),
                    SizedBox(width: 8),
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: _getUserProfileImage(),
                      child: _getUserProfileImage() == null && Authorization.username != null
                          ? Text(Authorization.username!.substring(0, 1).toUpperCase())
                          : null,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: widget.child ?? Container(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Početna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Trgovina',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cut),
            label: 'Usluge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Recenzije',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range),
            label: 'Termini',
          ),
        ],
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
      ),
    );
  }
}

