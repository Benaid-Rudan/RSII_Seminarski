import 'package:ebarbershop_mobile/providers/product_provider.dart';
import 'package:ebarbershop_mobile/screens/cart_screen.dart';
import 'package:ebarbershop_mobile/screens/product_details.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:ebarbershop_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductListScreen extends StatefulWidget {
  static const String routeName = "/product";

  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
   ProductProvider? _productProvider = null;
  CartProvider? _cartProvider = null;
  List<Product> data = [];
  TextEditingController _searchController = TextEditingController();
  bool _sortAscending = true;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _cartProvider = context.read<CartProvider>();
    print("called initState");
    loadData();
  }

  @override
  void dispose() {
    _mounted = false; 
    _searchController.dispose(); 
    super.dispose();
  }

  Future loadData() async {
    try {
      var tmpData = await _productProvider?.get();
      if (_mounted) { 
        setState(() {
          data = tmpData?.result ?? [];
        });
      }
    } catch (e) {
      print("Error loading products: $e");
    }
  }

  Future<void> _searchProducts(String value) async {
    try {
      var tmpData = await _productProvider?.get(filter: {'naziv': value});
      if (_mounted) {
        setState(() {
          data = tmpData?.result ?? [];
          _sortAscending = true;
        });
      }
    } catch (e) {
      print("Error searching products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("called build $data");

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Product List"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, CartScreen.routeName);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildProductSearch(),
              Container(
                height: 500,
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 30),
                  scrollDirection: Axis.vertical,
                  children: _buildProductCardList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text("Products", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w600),),
    );
  }

  Widget _buildProductSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) async {
                await _searchProducts(value);
              },
              onSubmitted: (value) async {
                await _searchProducts(value);
              },
              decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey))),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
                data.sort((a, b) => _sortAscending 
                    ? (a.cijena ?? 0).compareTo(b.cijena ?? 0) 
                    : (b.cijena ?? 0).compareTo(a.cijena ?? 0));
              });
            },
          ),
        )
      ],
    );
  }

  List<Widget> _buildProductCardList() {
    if (data.isEmpty) {
      return [
        Container(
          alignment: Alignment.center,
          height: 300, 
          child: Text(
            "No products found",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        )
      ];
    }

    List<Widget> list = data.map((x) => Container(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                "${ProductDetailsScreen.routeName}/${x.proizvodId}",
                arguments: x.proizvodId,
              );
            },
            child: Container(
              height: 100,
              width: 100,
              child: _buildProductImage(x.slika), 
            ),
          ),
          Text(x.naziv ?? ""),
          Text("Cijena: ${formatNumber(x.cijena)} KM"),
          
        const SizedBox(height: 4),
        if ((x.zalihe ?? 0) > 0) 
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => _cartProvider?.addToCart(x, context),
          )
        else
          Text(
            "Nema na stanju",
            style: TextStyle(color: Colors.red),
          ),
      ],
    ),
  )).cast<Widget>().toList();

    return list;
  }
}

  Widget _buildProductImage(String? image) {
    if (image == null || image.isEmpty) {
      return Icon(Icons.image); 
    }

    if (image.startsWith("http")) {
      return Image.network(Uri.encodeFull(image), fit: BoxFit.cover);
    } else {
      return imageFromBase64String(image);
    }
  }
