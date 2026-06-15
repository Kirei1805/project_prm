import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: adminViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminViewModel.allOrders.isEmpty
              ? const Center(
                  child: Text(
                    'No orders found.',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: adminViewModel.allOrders.length,
                  itemBuilder: (context, index) {
                    final order = adminViewModel.allOrders[index];
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Order #${order.id.isEmpty ? 'Pending' : order.id}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(order.totalAmount),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Customer ID: ${order.userId}', style: const TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Status: ', style: TextStyle(color: AppColors.textSecondary)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(order.status).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24, color: AppColors.textSecondary),
                            const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildStatusButton(context, order.id, 'Pending', adminViewModel),
                                _buildStatusButton(context, order.id, 'Processing', adminViewModel),
                                _buildStatusButton(context, order.id, 'Shipped', adminViewModel),
                                _buildStatusButton(context, order.id, 'Delivered', adminViewModel),
                                _buildStatusButton(context, order.id, 'Cancelled', adminViewModel),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusButton(BuildContext context, String orderId, String status, AdminViewModel viewModel) {
    return ActionChip(
      label: Text(status, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.background,
      side: BorderSide(color: _getStatusColor(status)),
      onPressed: () {
        viewModel.updateOrderStatus(orderId, status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $status')),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
