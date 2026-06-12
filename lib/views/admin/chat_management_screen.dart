import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';

class ChatManagementScreen extends StatelessWidget {
  const ChatManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AdminViewModel>(context);
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Support Chats')),
      body: adminViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<String>>(
              stream: firestoreService.getActiveChatsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Stream Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }

                final activeChatIds = snapshot.data ?? [];
                
                // Lọc ra những khách hàng có nằm trong danh sách activeChatIds
                // và sắp xếp theo đúng thứ tự của activeChatIds (mới nhất lên đầu)
                final activeCustomers = activeChatIds.map((chatId) {
                  try {
                    return adminViewModel.allUsers.firstWhere((u) => u.id == chatId);
                  } catch (e) {
                    return null;
                  }
                }).where((u) => u != null && u.role != 'admin').toList();

                if (activeCustomers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No active support chats.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = activeCustomers[index]!;
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.accent,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          customer.name.isEmpty ? 'Unknown Customer' : customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(customer.email, style: const TextStyle(color: AppColors.textSecondary)),
                        trailing: const Icon(Icons.chat, color: AppColors.accent),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: {
                              'chatId': customer.id,
                              'name': 'Chat with ${customer.name}',
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
