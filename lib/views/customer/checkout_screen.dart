import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String _selectedPaymentMethod = 'Cash On Delivery';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      final cart = Provider.of<CartViewModel>(context, listen: false);
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

      if (auth.currentUser == null) return;

      final success = await orderViewModel.placeOrder(auth.currentUser!.id, cart);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderViewModel.errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartViewModel>(context);
    final orderViewModel = Provider.of<OrderViewModel>(context);
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Shipping Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.name,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                readOnly: true, // We take it from auth
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.phone,
                decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Delivery Address', prefixIcon: Icon(Icons.location_on)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your delivery address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Cash On Delivery'),
                      value: 'Cash On Delivery',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      activeColor: AppColors.accent,
                    ),
                    RadioListTile<String>(
                      title: const Text('Bank Transfer'),
                      value: 'Bank Transfer',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      activeColor: AppColors.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items Total:', style: TextStyle(color: AppColors.textSecondary)),
                        Text('\$${cart.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Shipping Fee:', style: TextStyle(color: AppColors.textSecondary)),
                        Text('Free', style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                    const Divider(color: AppColors.textSecondary, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: orderViewModel.isLoading ? null : _placeOrder,
                child: orderViewModel.isLoading
                    ? const CircularProgressIndicator(color: AppColors.background)
                    : const Text('PLACE ORDER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
