import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';

class ProductViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<CategoryModel> _categories = [];
  
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategoryId;
  
  int _pageSize = 10;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  
  // Advanced filters
  double? _minPrice;
  double? _maxPrice;
  List<String> _selectedBrands = [];

  List<ProductModel> get products => _filteredProducts.take(_pageSize * _currentPage).toList();
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasMore => (_pageSize * _currentPage) < _filteredProducts.length;
  bool get isFetchingMore => _isFetchingMore;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  List<String> get selectedBrands => _selectedBrands;

  // Extract unique brands from all products
  List<String> get availableBrands {
    final brands = _allProducts.map((p) => p.brand).where((b) => b.isNotEmpty).toSet().toList();
    brands.sort();
    return brands;
  }

  // Smart Recommendation Feature (Rule-Based)
  List<ProductModel> get recommendedProducts {
    if (_searchQuery.toLowerCase().contains('irrigation')) {
      final recommendedNames = ['ESP32', 'Relay Module', 'Water Pump', 'Soil Moisture Sensor'];
      return _allProducts.where((p) {
        return recommendedNames.any((name) => p.name.toLowerCase().contains(name.toLowerCase()));
      }).toList();
    }
    return [];
  }

  StreamSubscription? _productsSubscription;
  StreamSubscription? _categoriesSubscription;

  ProductViewModel();

  /// Gọi khi HomeScreen được mở
  void initIfNeeded() {
    if (_productsSubscription == null) {
      _initStreams();
    }
  }

  void _initStreams() {
    _categoriesSubscription = _firestoreService.getCategoriesStream().listen((cats) {
      _categories = cats;
      notifyListeners();
    });

    _productsSubscription = _firestoreService.getProductsStream().listen((prods) {
      _allProducts = prods;
      _isLoading = false;
      _applyFilters(); // _applyFilters already calls notifyListeners()
    }, onError: (e) {
      print('Lỗi Stream Products: $e');
      _isLoading = false;
      notifyListeners();
    });
    
    // Timeout nếu stream không nhận được data (emulator IPv6 issue)
    Future.delayed(const Duration(seconds: 3), () {
      if (_isLoading) {
        print('Cảnh báo: Stream bị treo, tự động tắt loading!');
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Timer? _debounce;

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
  }

  void setAdvancedFilters({double? minPrice, double? maxPrice, List<String>? brands}) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    if (brands != null) {
      _selectedBrands = List.from(brands);
    } else {
      _selectedBrands.clear();
    }
    _applyFilters();
  }
  
  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedBrands.clear();
    _applyFilters();
  }

  void _applyFilters() {
    _currentPage = 1;
    _filteredProducts = _allProducts.where((product) {
      bool matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                           product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesCategory = _selectedCategoryId == null || product.categoryId == _selectedCategoryId;
      
      bool matchesMinPrice = _minPrice == null || product.price >= _minPrice!;
      bool matchesMaxPrice = _maxPrice == null || product.price <= _maxPrice!;
      bool matchesBrand = _selectedBrands.isEmpty || _selectedBrands.contains(product.brand);
      
      return matchesSearch && matchesCategory && matchesMinPrice && matchesMaxPrice && matchesBrand;
    }).toList();
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isFetchingMore || !hasMore) return;
    
    _isFetchingMore = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    _currentPage++;
    _isFetchingMore = false;
    notifyListeners();
  }

  // Smart Recommendation (Rule-Based)
  // Recommends products in the same category, excluding the current product, sorted by stock availability
  List<ProductModel> getRecommendations(String currentProductId, String categoryId, {int limit = 4}) {
    final recommendations = _allProducts.where((p) => 
      p.categoryId == categoryId && p.id != currentProductId
    ).toList();
    
    // Sort by stock (higher stock = more recommended)
    recommendations.sort((a, b) => b.stock.compareTo(a.stock));
    
    return recommendations.take(limit).toList();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    super.dispose();
  }
}
