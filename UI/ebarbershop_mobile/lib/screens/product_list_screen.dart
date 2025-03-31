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
import '../../widgets/ebarbershop_drawer.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _cartProvider = context.read<CartProvider>();
    print("called initState");
    loadData();
  }

  Future loadData() async {
    var tmpData = await _productProvider?.get();
    setState(() {
      data = tmpData?.result ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    print("called build $data");

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Product List"),
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
                      childAspectRatio: 4 / 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 30),
                  scrollDirection: Axis.horizontal,
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
              onSubmitted: (value) async {
                var tmpData = await _productProvider?.get(filter: {'naziv': value});
                setState(() {
                  data = tmpData?.result ?? [];
                });
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
            onPressed: () async {
                var tmpData = await _productProvider?.get(filter: {'naziv': _searchController.text});
                setState(() {
                  data = tmpData?.result ?? [];
                });
            },
          ),
        )
      ],
    );
  }


  List<Widget> _buildProductCardList() {
  if (data.length == 0) {
    return [Text("Loading...")];
  }

  List<Widget> list = data
      .map((x) => Container(
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
                IconButton(
  icon: Icon(Icons.shopping_cart),
  onPressed: () {
    _cartProvider?.addToCart(x);
    setState(() {
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("${x.naziv} dodan u korpu"),
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
  },
),
              ],
            ),
          ))
      .cast<Widget>()
      .toList();

  return list;
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
}