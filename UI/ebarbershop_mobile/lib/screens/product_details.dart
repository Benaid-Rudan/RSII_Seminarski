import 'package:flutter/material.dart';
import 'package:ebarbershop_mobile/models/product.dart';
import 'package:ebarbershop_mobile/providers/product_provider.dart';
import 'package:ebarbershop_mobile/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String routeName = "/product_details";
  final String proizvodId;

  const ProductDetailsScreen({required this.proizvodId, Key? key}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductProvider? _productProvider;
  Product? _product;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      var product = await _productProvider?.getById(int.parse(widget.proizvodId));
      if (mounted) {
        setState(() {
          _product = product;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri učitavanju proizvoda: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    if (_product == null) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final cartProvider = context.read<CartProvider>();
      cartProvider.addToCart(_product!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("${_product!.naziv} dodan u korpu"),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        backgroundColor: Colors.white,
      ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Text("Greška pri dodavanju u korpu: ${e.toString()}"),
          ),
        ],
      ),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
      backgroundColor: Colors.red[700], // Tamnija nijansa crvene
      elevation: 6, // Sjena za bolji 3D efekt
    ),
  );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalji proizvoda"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _product == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      child: _buildProductImage(_product!.slika),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _product!.naziv ?? "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Cijena: ${formatNumber(_product!.cijena)} KM",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isAddingToCart ? null : _addToCart,
                    child: _isAddingToCart
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Dodaj u korpu"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Opis proizvoda",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _product!.opis ?? "Nema dostupnog opisa",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductImage(String? image) {
    if (image == null || image.isEmpty) {
      return const Icon(Icons.image, size: 100);
    }
    if (image.startsWith("http")) {
      return Image.network(Uri.encodeFull(image), fit: BoxFit.cover);
    } else {
      return imageFromBase64String(image);
    }
  }
}