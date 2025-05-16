import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebarbershop_mobile/models/product.dart';
import 'package:ebarbershop_mobile/providers/product_provider.dart';
import 'package:ebarbershop_mobile/screens/product_details.dart';
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
  _loadData();
}

bool _mounted = true;

@override
void dispose() {
  _mounted = false;
  super.dispose();
}

Future<void> _loadData() async {
  await Future.wait([
    _loadNovosti(),
    _loadRecommendedProducts()
  ]);
}

Future<void> _loadRecommendedProducts() async {
  try {
    print("Fetching recommended products for user: ${Authorization.userId}");
    var data = await _productProvider.recommend(Authorization.userId!);
    print("API returned ${data.length} products:");
    data.forEach((p) => print(" - ${p.naziv} (ID: ${p.proizvodId})"));
    
    if (_mounted) {
      setState(() {
        recommendedProducts = data;
      });
    }
  } catch (e) {
    print("Error loading recommended products: $e");
    if (_mounted) {
      setState(() {
        recommendedProducts = []; 
      });
    }
  }
}

Future<void> _loadNovosti() async {
  try {
    var data = await _novostProvider.get();
    if (_mounted) {
      setState(() {
        novosti = data.result;
      });
    }
  } catch (e) {
    print("Error loading novosti: $e");
  }
}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Dobrodošao ${Authorization.username}',
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
                      'Početna strana',
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
                      'Galerija',
                      style: TextStyle(
                        color: _showGallery ? Colors.amber[800] : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
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
              : SliverToBoxAdapter(
                  child: _buildHorizontalNovostiSection(),
                ),
            
            if (recommendedProducts.isNotEmpty && !_showGallery)
              SliverToBoxAdapter(
                child: _buildRecommendedProductsSection(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalNovostiSection() {
    if (novosti.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Najnovije vijesti',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, 
            itemCount: novosti.length,
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              return _buildNovostCardHorizontal(novosti[index]);
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildNovostCardHorizontal(Novost novost) {
  return Container(
    width: 150,
    margin: EdgeInsets.symmetric(horizontal: 6),
    child: Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: _buildNovostImage(novost),
              ),
          ),
          
          Container(
            width: double.infinity, 
            constraints: BoxConstraints(minHeight: 70),
            padding: EdgeInsets.all(8.0), 
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity, 
                child: Text(
                  novost.naslov ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 4), 
              if (novost.sadrzaj != null)
                Container(
                  width: double.infinity, 
                  child: Text(
                    novost.sadrzaj!,
                    style: TextStyle(
                      fontSize: 11, 
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        ],
      ),
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
        width: double.infinity,
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
    if (recommendedProducts.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Text(
            'Preporučeni proizvodi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedProducts.length,
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              return _buildRecommendedProductCard(recommendedProducts[index]);
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecommendedProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(proizvodId: product.proizvodId?.toString() ?? ''),
        ),
      );
      },
      child: Container(
        width: 160,
        height: 220,
        margin: EdgeInsets.symmetric(horizontal: 6),
        child: Card(
          elevation: 3,
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    color: Colors.white,
                    child: _buildProductImage(product.slika),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 80,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        product.naziv ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${formatNumber(product.cijena)} KM",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[900],
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        width: double.infinity,
          fit: BoxFit.cover,
      );
    } catch (e) {
      print("Error decoding image: $e");
      return _buildErrorWidget();
    }
  }
  
}
}