import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../services/vnpay_service.dart';
import 'vnpay_payment_screen.dart';
import '../../utils/currency_formatter.dart';
import 'store_location_screen.dart';
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
  void initState() {
    super.initState();
    // Initialize address if user already has it saved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
      if (user != null && user.address.isNotEmpty) {
        _addressController.text = user.address;
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showAddressBook() {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // Use StatefulBuilder if we want to update the UI inside the bottom sheet
        return Consumer<AuthViewModel>(
          builder: (context, authVM, child) {
            final savedAddresses = authVM.currentUser?.savedAddresses ?? [];
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Saved Addresses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  if (savedAddresses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No saved addresses yet. Type an address or pick from the map to save it.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: savedAddresses.length,
                        itemBuilder: (context, index) {
                          final addr = savedAddresses[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: AppColors.accent),
                            title: Text(addr, style: const TextStyle(color: AppColors.textPrimary)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () {
                                authVM.removeSavedAddress(addr);
                              },
                            ),
                            onTap: () {
                              setState(() {
                                _addressController.text = addr;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      final cart = Provider.of<CartViewModel>(context, listen: false);
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

      if (auth.currentUser == null) return;
      
      if (cart.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty!'), backgroundColor: AppColors.error),
        );
        return;
      }

      // Generate a unique order ID
      final String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      if (_selectedPaymentMethod == 'Bank Transfer (VNPAY)') {
        final paymentUrl = VNPayService.generatePaymentUrl(
          orderId: orderId,
          amount: cart.totalAmount,
          orderInfo: 'Payment_Order_$orderId',
        );

        final isSuccess = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VNPayPaymentScreen(paymentUrl: paymentUrl),
          ),
        );

        if (isSuccess == true) {
          // Proceed to place order
          await _submitOrder(orderViewModel, auth.currentUser!.id, cart, auth);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment cancelled or failed!'), backgroundColor: AppColors.error),
          );
        }
      } else {
        await _submitOrder(orderViewModel, auth.currentUser!.id, cart, auth);
      }
    }
  }

  Future<void> _submitOrder(OrderViewModel orderViewModel, String userId, CartViewModel cart, AuthViewModel auth) async {
    // Save address if changed
    if (_addressController.text.isNotEmpty && auth.currentUser?.address != _addressController.text) {
      await auth.updateAddress(_addressController.text);
      await auth.addSavedAddress(_addressController.text);
    } else if (_addressController.text.isNotEmpty) {
      await auth.addSavedAddress(_addressController.text);
    }

    final success = await orderViewModel.placeOrder(userId, cart, paymentMethod: _selectedPaymentMethod);

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
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map, color: AppColors.accent),
                    tooltip: 'Pick from Map',
                    onPressed: () async {
                      final selectedAddress = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StoreLocationScreen(isPickerMode: true),
                        ),
                      );
                        if (selectedAddress != null && selectedAddress is String) {
                          setState(() {
                            _addressController.text = selectedAddress;
                          });
                          final auth = Provider.of<AuthViewModel>(context, listen: false);
                          if (auth.currentUser != null) {
                            auth.addSavedAddress(selectedAddress);
                          }
                        }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your delivery address';
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _showAddressBook,
                  icon: const Icon(Icons.import_contacts, size: 18, color: AppColors.accent),
                  label: const Text('Address Book', style: TextStyle(color: AppColors.accent)),
                ),
              ),
              const SizedBox(height: 16),
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
                      title: const Text('Bank Transfer (Online Payment)'),
                      value: 'Bank Transfer (VNPAY)',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      activeColor: AppColors.accent,
                    ),
                    if (_selectedPaymentMethod == 'Bank Transfer (VNPAY)')
                      Padding(
                        padding: const EdgeInsets.only(left: 72.0, right: 16.0, bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.security, color: AppColors.accent, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Giao dịch an toàn qua Cổng thanh toán VNPAY (Sandbox)',
                                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        Text(CurrencyFormatter.format(cart.totalAmount), style: const TextStyle(color: AppColors.textPrimary)),
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
                          CurrencyFormatter.format(cart.totalAmount),
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
