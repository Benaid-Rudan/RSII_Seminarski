
import 'package:ebarbershop_mobile/models/cart.dart';
import 'package:ebarbershop_mobile/models/product.dart';
import 'package:ebarbershop_mobile/providers/cart_provider.dart';
import 'package:ebarbershop_mobile/providers/product_provider.dart';
import 'package:ebarbershop_mobile/providers/uplata_provider.dart';
import 'package:ebarbershop_mobile/screens/paypal_payment_screen.dart';
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

  late CartProvider _cartProvider;
  late NarudzbaProvider _orderProvider;
  
  @override
  void initState() {
    super.initState();
    
  }

  @override
  void didChangeDependencies() {
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
                  Text("Vratite se nazad da pogledate proizvode"),
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
  return FutureBuilder(
    future: context.read<ProductProvider>().getById(item.product.proizvodId!),
    builder: (context, snapshot) {
      final product = snapshot.data as Product?;
      final isOutOfStock = snapshot.hasData && (product?.zalihe ?? 0) < item.count;
      
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: isOutOfStock ? Colors.red.withOpacity(0.2) : null,
        child: ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: _buildProductImage(item.product.slika),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.product.naziv ?? ""),
              if (isOutOfStock)
                Text(
                  "Nema dovoljno zaliha",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
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
                onPressed: isOutOfStock 
                    ? null  
                    : () => _cartProvider.incrementCount(item.product,context),
              ),
            ],
          ),
        ),
      );
    },
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
Future<bool> _payWithPayPal(BuildContext context) async {
  if (_cartProvider.cart.items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Košarica je prazna")),
    );
    return false;
  }

  if (Authorization.userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Morate biti prijavljeni")),
    );
    return false;
  }

  final outOfStockProducts = await _checkProductAvailability();
  if (outOfStockProducts.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Sljedeći proizvodi nemaju dovoljno zaliha: ${outOfStockProducts.join(', ')}"),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }

  double ukupnaCijenaKM = _cartProvider.cart.items.fold(
    0,
    (total, item) => total + (item.product.cijena! * item.count),
  );
  double ukupnaCijenaUSD = ukupnaCijenaKM * 0.56;

  final listaProizvoda = _cartProvider.cart.items.map((item) {
    return {
      "proizvodID": item.product.proizvodId,
      "kolicina": item.count,
      "naziv": item.product.naziv ?? "Proizvod",
      "cijena": item.product.cijena! * 0.56,
    };
  }).toList();

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (context) => PaypalPaymentScreen(
        totalPrice: ukupnaCijenaUSD,
        listaProizvoda: listaProizvoda,
        korisnikId: Authorization.userId!,
        onPaymentSuccess: () async {
          await _completeOrderAfterPayment(ukupnaCijenaKM, listaProizvoda);
          return true;
        },
      ),
    ),
  );

  if (result == true && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Plaćanje uspješno izvršeno"),
        backgroundColor: Colors.green,
      ),
    );
    return true;
  }
  return false;
}

Future<void> _completeOrderAfterPayment(double ukupnaCijena, List<Map<String, dynamic>> listaProizvoda) async {
  try {
    final order = {
      "datum": DateTime.now().toIso8601String(),
      "ukupnaCijena": ukupnaCijena,
      "korisnikId": Authorization.userId,
      "listaProizvoda": listaProizvoda,
    };

    final createdOrder = await _orderProvider.insert(order);

    final payment = {
      "iznos": ukupnaCijena,
      "nacinUplate": "PayPal", 
      "narudzbaId": createdOrder.narudzbaId,
      "datumUplate": DateTime.now().toIso8601String(),
    };

    await _createPaymentRecord(payment);

    await _updateProductStocks(listaProizvoda);
    _cartProvider.clearCart(); 
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Narudžba i uplata uspješno evidentirani"),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print("Greška pri spremanju narudžbe nakon plaćanja: $e");
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

Future<void> _createPaymentRecord(Map<String, dynamic> paymentData) async {
  try {
    final paymentProvider = context.read<UplataProvider>();
    await paymentProvider.insert(paymentData);
  } catch (e) {
    print("Greška pri kreiranju uplate: $e");
    throw Exception("Došlo je do greške pri evidentiranju uplate");
  }
}

Future<void> _updateProductStocks(List<Map<String, dynamic>> listaProizvoda) async {
  try {
    final productProvider = context.read<ProductProvider>();
    
    for (var item in listaProizvoda) {
      final proizvodId = item['proizvodID'];
      final kolicina = item['kolicina'];
      
      final proizvod = await productProvider.getById(proizvodId);
      
      if (proizvod != null) {
        final noveZalihe = (proizvod.zalihe ?? 0) - kolicina;
        
        await productProvider.update(proizvodId, {
          'zalihe': noveZalihe,
          'naziv': proizvod.naziv,
          'opis': proizvod.opis,
          'cijena': proizvod.cijena,
          'slika': proizvod.slika,
          'vrstaProizvodaId': proizvod.vrstaProizvodaId,
        });
      }
    }
  } catch (e) {
    print("Greška pri ažuriranju zaliha: $e");
    throw Exception("Došlo je do greške pri ažuriranju zaliha");
  }
}
Future<List<String>> _checkProductAvailability() async {
  final productProvider = context.read<ProductProvider>();
  List<String> outOfStockProducts = [];

  for (var item in _cartProvider.cart.items) {
    try {
      final proizvod = await productProvider.getById(item.product.proizvodId!);
      if (proizvod == null || (proizvod.zalihe ?? 0) < item.count) {
        outOfStockProducts.add(item.product.naziv ?? "Proizvod ID: ${item.product.proizvodId}");
      }
    } catch (e) {
      print("Greška pri provjeri zaliha za proizvod ${item.product.proizvodId}: $e");
      outOfStockProducts.add(item.product.naziv ?? "Proizvod ID: ${item.product.proizvodId}");
    }
  }

  return outOfStockProducts;
}
}