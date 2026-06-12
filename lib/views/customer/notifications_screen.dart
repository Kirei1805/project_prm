import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy notifications for demonstration purposes
    final List<Map<String, String>> notifications = [
      {
        'title': 'Order Shipped!',
        'body': 'Your order #12345 has been shipped and is on its way.',
        'time': '2 hours ago',
      },
      {
        'title': 'Welcome to ElectroHub',
        'body': 'Thank you for registering. Check out our latest electronic components!',
        'time': '1 day ago',
      },
      {
        'title': 'Discount 20% OFF',
        'body': 'Flash sale on all microcontrollers this weekend.',
        'time': '2 days ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            color: AppColors.surface,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.accent,
                child: Icon(Icons.notifications, color: Colors.white),
              ),
              title: Text(
                notif['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notif['body']!, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(notif['time']!, style: const TextStyle(color: AppColors.accent, fontSize: 12)),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
