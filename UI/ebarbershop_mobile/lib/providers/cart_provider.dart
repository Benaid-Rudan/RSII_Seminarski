import 'package:ebarbershop_mobile/models/cart.dart';
import 'package:ebarbershop_mobile/models/product.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class CartProvider with ChangeNotifier {
  Cart cart = Cart();

  void addToCart(Product product) {
    final existingItem = findInCart(product);
    if (existingItem != null) {
      existingItem.count++;
    } else {
      cart.items.add(CartItem(product, 1));
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    cart.items.removeWhere((item) => item.product.proizvodId == product.proizvodId);
    notifyListeners();
  }

  void incrementCount(Product product) {
    final item = findInCart(product);
    if (item != null) {
      item.count++;
      notifyListeners();
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