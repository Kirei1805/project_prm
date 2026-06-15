import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<OrderViewModel>(context, listen: false).subscribeToUserOrders(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: orderViewModel.isLoading && orderViewModel.userOrders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : orderViewModel.userOrders.isEmpty
              ? const Center(
                  child: Text(
                    'You have no orders yet.',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderViewModel.userOrders.length,
                  itemBuilder: (context, index) {
                    final order = orderViewModel.userOrders[index];
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          'Order #${order.id.isEmpty ? 'Pending' : order.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Status: ${order.status}', style: const TextStyle(color: AppColors.accent)),
                            const SizedBox(height: 4),
                            Text('Method: ${order.paymentMethod}', style: const TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('Items: ${order.items.length}', style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                        trailing: Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.accent,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/order_detail', arguments: order);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
