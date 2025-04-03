import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebarbershop_mobile/providers/novost_provider.dart';
import 'package:ebarbershop_mobile/models/novost.dart';
import 'package:ebarbershop_mobile/utils/util.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NovostProvider _novostProvider;
  List<Novost> novosti = [];
  bool _showGallery = false; 

  @override
  void initState() {
    super.initState();
    _novostProvider = context.read<NovostProvider>();
    _loadNovosti();
  }

  Future<void> _loadNovosti() async {
    try {
      var data = await _novostProvider.get();
      setState(() {
        novosti = data.result;
      });
    } catch (e) {
      print("Error loading novosti: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome ${Authorization.username}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showGallery = false; 
                  });
                },
                child: Text(
                  'Feed',
                  style: TextStyle(
                    color: !_showGallery ? Colors.amber[800] : Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showGallery = true; 
                  });
                },
                child: Text(
                  'Gallery',
                  style: TextStyle(
                    color: _showGallery ? Colors.amber[800] : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: _showGallery 
                  ? _buildGalleryView() 
                  : _buildFeedView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: novosti.length,
      itemBuilder: (context, index) {
        return _buildNovostCard(novosti[index]);
      },
    );
  }

  Widget _buildGalleryView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,  
        childAspectRatio: 1, 
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: novosti.length,
      itemBuilder: (context, index) {
        return _buildGalleryImage(novosti[index]);
      },
    );
  }

  Widget _buildNovostCard(Novost novost) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: _buildNovostImage(novost),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              novost.naslov ?? '',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryImage(Novost novost) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: _buildNovostImage(novost),
    );
  }

  Widget _buildNovostImage(Novost novost) {
    if (novost.slika == null || novost.slika!.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
      );
    }

    if (novost.slika!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: novost.slika!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      );
    } else {
      try {
        String base64Data = novost.slika!.startsWith('data:image') 
            ? novost.slika!.split(',').last 
            : novost.slika!;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
        );
      } catch (e) {
        return _buildErrorWidget();
      }
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}