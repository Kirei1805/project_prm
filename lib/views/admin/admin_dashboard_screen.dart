import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future(() {
      if (mounted) {
        Provider.of<AdminViewModel>(context, listen: false).initIfNeeded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: AppColors.accent)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthViewModel>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.surface),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 60, color: AppColors.accent),
                  SizedBox(height: 10),
                  Text('Admin Menu', style: TextStyle(color: AppColors.textPrimary, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: AppColors.accent),
              title: const Text('Dashboard', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(context), // Already here
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: AppColors.textPrimary),
              title: const Text('Products', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin_products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, color: AppColors.textPrimary),
              title: const Text('Orders', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin_orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: AppColors.textPrimary),
              title: const Text('Users', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin_users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppColors.textPrimary),
              title: const Text('Support Chats', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin_chats');
              },
            ),
          ],
        ),
      ),
      body: admin.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard('Total Products', '${admin.totalProducts}', Icons.inventory, Colors.blue),
                      _buildStatCard('Total Users', '${admin.totalUsers}', Icons.people, Colors.green),
                      _buildStatCard('Total Orders', '${admin.totalOrders}', Icons.shopping_bag, Colors.orange),
                      _buildStatCard('Revenue', CurrencyFormatter.format(admin.totalRevenue), Icons.attach_money, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  admin.recentOrders.isEmpty
                      ? const Text('No orders found.', style: TextStyle(color: AppColors.textSecondary))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: admin.recentOrders.length,
                          itemBuilder: (context, index) {
                            final order = admin.recentOrders[index];
                            return Card(
                              color: AppColors.surface,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${order.items.length} items - ${order.status}'),
                                trailing: Text(CurrencyFormatter.format(order.totalAmount), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
