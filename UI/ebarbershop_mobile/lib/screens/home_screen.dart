import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebarbershop_mobile/models/product.dart';
import 'package:ebarbershop_mobile/providers/product_provider.dart';
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
  List<Product> recommendedProducts = [];
  late ProductProvider _productProvider;
  bool _showGallery = false; 

  @override
  void initState() {
    super.initState();
    _novostProvider = context.read<NovostProvider>();
    _productProvider = context.read<ProductProvider>();
    _loadNovosti();
    _loadRecommendedProducts();
  }
  Future<void> _loadRecommendedProducts() async {
    try {
      print("Fetching recommended products...");
      var data = await _productProvider.getRecommended();
      print("Received recommended products: ${data.length}");
      setState(() {
        recommendedProducts = data;
      });
    } catch (e) {
      print("Error loading recommended products: $e");
    }
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
    body: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Align(
      alignment: Alignment.center,
      child: Text(
        'Welcome ${Authorization.username}',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  ),
),
        
        SliverToBoxAdapter(
          child: Row(
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
        ),
        
        // Feed/Gallery content
        _showGallery 
          ? SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildGalleryImage(novosti[index]),
                childCount: novosti.length,
              ),
            )
          : SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildNovostCard(novosti[index]),
                childCount: novosti.length,
              ),
            ),
        
        // Recommended products section
        if (recommendedProducts.isNotEmpty && !_showGallery)
          SliverToBoxAdapter(
            child: _buildRecommendedProductsSection(),
          ),
      ],
    ),
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
  Widget _buildRecommendedProductsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          'Preporučeni proizvodi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: recommendedProducts.length,
          padding: EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (context, index) {
            return _buildRecommendedProductCard(recommendedProducts[index]);
          },
        ),
      ),
    ],
  );
}

Widget _buildRecommendedProductCard(Product product) {
  return Container(
    width: 140,
    margin: EdgeInsets.symmetric(horizontal: 6),
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centriraj sve po horizontali
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Center( // Dodaj Center widget za sliku
                child: _buildProductImage(product.slika),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Centriraj tekst
              children: [
                Text(
                  product.naziv ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2, // Povećaj broj linija ako je potrebno
                  textAlign: TextAlign.center, // Centriraj tekst unutar Text widgeta
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "${formatNumber(product.cijena)} KM",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.amber[800],
                  ),
                  textAlign: TextAlign.center, // Centriraj cijenu
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildProductImage(String? image) {
  if (image == null || image.isEmpty) {
    return Container(
      color: Colors.grey[200],
      child: Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
    );
  }

  if (image.startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: image,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );
  } else {
    try {
      String base64Data = image.startsWith('data:image') 
          ? image.split(',').last 
          : image;
      return Image.memory(
        base64Decode(base64Data),
        fit: BoxFit.cover,
      );
    } catch (e) {
      print("Error decoding image: $e");
      return _buildErrorWidget();
    }
  }
  
}
}