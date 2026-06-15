import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as OrderModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID: ${order.id.isEmpty ? 'Pending' : order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${order.status}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment Method: ${order.paymentMethod}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) {
              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.name, style: const TextStyle(color: AppColors.textPrimary)),
                  subtitle: Text('Quantity: ${item.quantity}', style: const TextStyle(color: AppColors.textSecondary)),
                  trailing: Text(
                    CurrencyFormatter.format(item.price * item.quantity),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    CurrencyFormatter.format(order.totalAmount),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
