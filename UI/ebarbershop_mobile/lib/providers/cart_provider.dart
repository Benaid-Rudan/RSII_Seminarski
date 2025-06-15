import 'package:ebarbershop_mobile/models/cart.dart';
import 'package:ebarbershop_mobile/models/product.dart';
import 'package:ebarbershop_mobile/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

class CartProvider with ChangeNotifier {
  Cart cart = Cart();

  Future<void> addToCart(Product product, BuildContext context) async {
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final currentProduct = await productProvider.getById(product.proizvodId!);
      
      if (currentProduct == null || (currentProduct.zalihe ?? 0) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${product.naziv} nije dostupan na stanju"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final existingItem = findInCart(product);
      final totalInCart = existingItem?.count ?? 0;
      
      if ((currentProduct.zalihe ?? 0) < totalInCart + 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Nema dovoljno zaliha za ${product.naziv}"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (existingItem != null) {
        existingItem.count++;
      } else {
        cart.items.add(CartItem(product, 1));
      }
      notifyListeners();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${product.naziv} dodan u košaricu"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri dodavanju u košaricu: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void clearCart() {
    cart.items.clear();
    notifyListeners();
  }

  void removeFromCart(Product product) {
    cart.items.removeWhere((item) => item.product.proizvodId == product.proizvodId);
    notifyListeners();
  }

  void incrementCount(Product product, BuildContext context) async {
    try {
      final item = findInCart(product);
      if (item != null) {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        final currentProduct = await productProvider.getById(product.proizvodId!);
        
        if (currentProduct == null || (currentProduct.zalihe ?? 0) <= item.count) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Nema dovoljno zaliha za ${product.naziv}"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        item.count++;
        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri ažuriranju količine: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void decrementCount(Product product) {
    final item = findInCart(product);
    if (item != null && item.count > 1) {
      item.count--;
      notifyListeners();
    }
  }

  CartItem? findInCart(Product product) {
    return cart.items.firstWhereOrNull(
      (item) => item.product.proizvodId == product.proizvodId,
    );
  }
}