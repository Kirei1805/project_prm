import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../viewmodels/cart_viewmodel.dart';

class OrderViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<OrderModel> _userOrders = [];
  bool _isLoading = false;
  String _errorMessage = '';
  StreamSubscription? _ordersSubscription;

  List<OrderModel> get userOrders => _userOrders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void subscribeToUserOrders(String userId) {
    _isLoading = true;
    notifyListeners();

    _ordersSubscription?.cancel();
    _ordersSubscription = _firestoreService.getUserOrdersStream(userId).listen((orders) {
      // Sort by creation date in descending order (we can add a timestamp field later, but for now we just show list)
      _userOrders = orders;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> placeOrder(String userId, CartViewModel cart, {String paymentMethod = 'Cash On Delivery'}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final items = cart.items.values.map((cartItem) {
        return OrderItemModel(
          productId: cartItem.product.id,
          name: cartItem.product.name,
          price: cartItem.product.price,
          quantity: cartItem.quantity,
        );
      }).toList();

      final order = OrderModel(
        id: '', // Firestore will generate ID
        userId: userId,
        status: paymentMethod == 'Bank Transfer (VNPAY)' ? 'Paid' : 'Pending',
        totalAmount: cart.totalAmount,
        paymentMethod: paymentMethod,
        items: items,
      );

      await _firestoreService.createOrder(order);
      cart.clearCart();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
