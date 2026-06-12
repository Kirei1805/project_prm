import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class CartViewModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount {
    int count = 0;
    _items.forEach((key, item) {
      count += item.quantity;
    });
    return count;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.totalPrice;
    });
    return total;
  }

  void addItem(ProductModel product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product, quantity: 1),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    
    _items.update(
      productId,
      (existingCartItem) => CartItem(
        product: existingCartItem.product,
        quantity: existingCartItem.quantity + 1,
      ),
    );
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Exposed methods for unit testing requirements
  double calculateTotal() {
    return totalAmount;
  }
}
