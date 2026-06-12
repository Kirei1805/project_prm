import 'package:flutter_test/flutter_test.dart';
import 'package:project_prm/models/product_model.dart';
import 'package:project_prm/viewmodels/cart_viewmodel.dart';

void main() {
  group('CartViewModel Tests', () {
    late CartViewModel cartViewModel;
    late ProductModel testProduct;

    setUp(() {
      cartViewModel = CartViewModel();
      testProduct = ProductModel(
        id: 'p1',
        name: 'Test Arduino',
        sku: 'ARD-01',
        description: 'Test board',
        price: 25.0,
        stock: 10,
        imageUrl: '',
        categoryId: 'c1',
        brand: 'Arduino',
        voltage: '5V',
      );
    });

    test('Initial cart should be empty', () {
      expect(cartViewModel.itemCount, 0);
      expect(cartViewModel.totalAmount, 0.0);
      expect(cartViewModel.items.length, 0);
    });

    test('Adding a product increases item count and total amount', () {
      cartViewModel.addItem(testProduct);

      expect(cartViewModel.itemCount, 1);
      expect(cartViewModel.totalAmount, 25.0);
      expect(cartViewModel.items.containsKey('p1'), true);
      expect(cartViewModel.items['p1']?.quantity, 1);
    });

    test('Adding same product increases quantity', () {
      cartViewModel.addItem(testProduct);
      cartViewModel.addItem(testProduct);

      expect(cartViewModel.itemCount, 2);
      expect(cartViewModel.totalAmount, 50.0);
      expect(cartViewModel.items['p1']?.quantity, 2);
    });

    test('Decreasing quantity works correctly', () {
      cartViewModel.addItem(testProduct);
      cartViewModel.addItem(testProduct);
      
      cartViewModel.decreaseQuantity('p1');

      expect(cartViewModel.itemCount, 1);
      expect(cartViewModel.totalAmount, 25.0);
      expect(cartViewModel.items['p1']?.quantity, 1);
    });

    test('Decreasing quantity to zero removes item', () {
      cartViewModel.addItem(testProduct);
      cartViewModel.decreaseQuantity('p1');

      expect(cartViewModel.itemCount, 0);
      expect(cartViewModel.items.containsKey('p1'), false);
    });

    test('Removing item clears it completely', () {
      cartViewModel.addItem(testProduct);
      cartViewModel.addItem(testProduct);
      
      cartViewModel.removeItem('p1');

      expect(cartViewModel.itemCount, 0);
      expect(cartViewModel.totalAmount, 0.0);
      expect(cartViewModel.items.containsKey('p1'), false);
    });

    test('Clearing cart removes all items', () {
      cartViewModel.addItem(testProduct);
      
      final product2 = ProductModel(
        id: 'p2',
        name: 'Sensor',
        sku: 'SEN-01',
        description: 'Test',
        price: 10.0,
        stock: 5,
        imageUrl: '',
        categoryId: 'c2',
        brand: 'Generic',
        voltage: '3.3V',
      );
      
      cartViewModel.addItem(product2);
      
      expect(cartViewModel.itemCount, 2);
      
      cartViewModel.clearCart();
      
      expect(cartViewModel.itemCount, 0);
      expect(cartViewModel.totalAmount, 0.0);
    });
  });
}
