import 'dart:convert';

import 'package:ebarbershop_mobile/models/cart.dart';
import 'package:ebarbershop_mobile/providers/cart_provider.dart';
import 'package:ebarbershop_mobile/screens/paypal_payment_screen.dart';
import 'package:ebarbershop_mobile/screens/product_list_screen.dart';
import 'package:ebarbershop_mobile/widgets/master_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../../providers/narudzba_provider.dart';
import '../../utils/util.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = "/cart";

  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
    bool _isProcessing = false;

  late CartProvider _cartProvider;
  late NarudzbaProvider _orderProvider;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _cartProvider = context.watch<CartProvider>();
    _orderProvider = context.read<NarudzbaProvider>();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: const Text("Košarica"),
    ),
    body: _cartProvider.cart.items.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Vaša košarica je prazna",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                     Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MasterScreenWidget(
                            child: ProductListScreen(),
                            title: "Proizvodi",
                          ),
                        ),
                      );
                  },
                  child: const Text("Pogledajte proizvode"),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: _buildProductCardList(),
              ),
              _buildBuyButton(),
            ],
          ),
  );
}
  Widget _buildProductCardList() {
    return Container(
      child: ListView.builder(
        itemCount: _cartProvider.cart.items.length,
        itemBuilder: (context, index) {
          return _buildProductCard(_cartProvider.cart.items[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(CartItem item) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: ListTile(
      leading: SizedBox(
        width: 50,
        height: 50,
        child: _buildProductImage(item.product.slika),
      ),
      title: Text(item.product.naziv ?? ""),
      subtitle: Text("${formatNumber(item.product.cijena)} KM"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              if (item.count > 1) {
                _cartProvider.decrementCount(item.product);
              } else {
                _cartProvider.removeFromCart(item.product);
              }
            },
          ),
          Text(item.count.toString()),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _cartProvider.incrementCount(item.product),
          ),
        ],
      ),
    ),
  );
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

  Widget _buildBuyButton() {
  if (_cartProvider.cart.items.isEmpty) {
    return Expanded(
      child: Center(
        child: Text(
          "Košarica je prazna",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: _processOrder,
          child: const Text(
            "POTVRDI NARUDŽBU",
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () => _payWithPayPal(context),
          child: const Text(
            "PLATI PUTEM PAYPAL-A",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
Future<void> _payWithPayPal(BuildContext context) async {
  if (_cartProvider.cart.items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Košarica je prazna")),
    );
    return;
  }

  if (Authorization.userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Morate biti prijavljeni")),
    );
    return;
  }

  // Izračunaj ukupnu cijenu i konvertiraj u USD
  double ukupnaCijenaKM = _cartProvider.cart.items.fold(
    0,
    (total, item) => total + (item.product.cijena! * item.count),
  );
  double ukupnaCijenaUSD = ukupnaCijenaKM * 0.56; // Pretpostavka 1 KM = 0.56 USD

  final listaProizvoda = _cartProvider.cart.items.map((item) {
    return {
      "proizvodID": item.product.proizvodId,
      "kolicina": item.count,
      "naziv": item.product.naziv ?? "Proizvod",
      "cijena": item.product.cijena! * 0.56, // Konvertiraj u USD
    };
  }).toList();

  try {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaypalPaymentScreen(
          totalPrice: ukupnaCijenaUSD,
          listaProizvoda: listaProizvoda,
          korisnikId: Authorization.userId!,
          onPaymentSuccess: () async {
            await _completeOrderAfterPayment(ukupnaCijenaKM, listaProizvoda);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Plaćanje uspješno izvršeno"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> _completeOrderAfterPayment(double ukupnaCijena, List<Map<String, dynamic>> listaProizvoda) async {
  try {
    final order = {
      "datum": DateTime.now().toIso8601String(),
      "ukupnaCijena": ukupnaCijena,
      "korisnikId": Authorization.userId,
      "listaProizvoda": listaProizvoda,
      // "status": "Plaćeno",
      "nacinPlacanja": "PayPal",
    };

    await _orderProvider.insert(order);
    _cartProvider.cart.items.clear();
    if (mounted) {
      setState(() {});
    }
  } catch (e) {
    print("Greška pri spremanju narudžbe nakon plaćanja: $e");
    throw e;
  }
}

Future<void> _processOrder() async {
  try {
    double ukupnaCijena = _cartProvider.cart.items.fold(
      0,
      (total, item) => total + (item.product.cijena! * item.count),
    );

    final listaProizvoda = _cartProvider.cart.items.map((item) {
      return {
        "proizvodID": item.product.proizvodId,
        "kolicina": item.count,
      };
    }).toList();

    final order = {
      "datum": DateTime.now().toIso8601String(),
      "ukupnaCijena": ukupnaCijena,
      "korisnikId": Authorization.userId,
      "listaProizvoda": listaProizvoda,
      // "status": "Na čekanju",
      "nacinPlacanja": "Gotovina",
    };

    await _orderProvider.insert(order);
    _cartProvider.cart.items.clear();
    if (mounted) {
      setState(() {});
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Narudžba uspješno kreirana"),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print("Greška pri narudžbi: $e"); 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
}