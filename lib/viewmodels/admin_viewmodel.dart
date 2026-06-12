import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class AdminViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<OrderModel> _allOrders = [];
  List<UserModel> _allUsers = [];
  List<ProductModel> _allProducts = [];

  StreamSubscription? _ordersSubscription;
  StreamSubscription? _usersSubscription;
  StreamSubscription? _productsSubscription;

  bool _isLoading = true;

  AdminViewModel() {
    _initStreams();
  }

  List<OrderModel> get allOrders => _allOrders;
  List<UserModel> get allUsers => _allUsers;
  List<ProductModel> get allProducts => _allProducts;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<ProductModel> get filteredProducts {
    if (_searchQuery.isEmpty) return _allProducts;
    return _allProducts.where((product) {
      final query = _searchQuery.toLowerCase();
      return product.name.toLowerCase().contains(query) || 
             product.brand.toLowerCase().contains(query);
    }).toList();
  }

  int get totalProducts => _allProducts.length;
  int get totalUsers => _allUsers.length;
  int get totalOrders => _allOrders.length;
  
  double get totalRevenue {
    double revenue = 0.0;
    for (var order in _allOrders) {
      if (order.status != 'Cancelled') {
        revenue += order.totalAmount;
      }
    }
    return revenue;
  }

  List<OrderModel> get recentOrders {
    // Assuming the orders are streamed, we'll just take the first 5 or so 
    // Ideally we'd sort by date, but since we don't have a date field we just show them.
    if (_allOrders.length > 5) {
      return _allOrders.sublist(0, 5);
    }
    return _allOrders;
  }

  void _initStreams() {
    _ordersSubscription = _firestoreService.getAllOrdersStream().listen((orders) {
      _allOrders = orders;
      _checkLoadingState();
    });

    _usersSubscription = _firestoreService.getAllUsersStream().listen((users) {
      _allUsers = users;
      _checkLoadingState();
    });

    _productsSubscription = _firestoreService.getProductsStream().listen((products) {
      _allProducts = products;
      _checkLoadingState();
    });
  }

  void _checkLoadingState() {
    // Basic loading state check
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestoreService.updateOrderStatus(orderId, newStatus);
  }

  Future<void> deleteProduct(String productId) async {
    await _firestoreService.deleteProduct(productId);
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _usersSubscription?.cancel();
    _productsSubscription?.cancel();
    super.dispose();
  }
}
