import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../utils/app_colors.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: adminViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminViewModel.allUsers.isEmpty
              ? const Center(
                  child: Text(
                    'No users found.',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: adminViewModel.allUsers.length,
                  itemBuilder: (context, index) {
                    final user = adminViewModel.allUsers[index];
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.role == 'admin' ? AppColors.accent : AppColors.background,
                          child: Icon(
                            user.role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                            color: user.role == 'admin' ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        title: Text(
                          user.name.isEmpty ? 'No Name' : user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(user.email, style: const TextStyle(color: AppColors.textSecondary)),
                            Text('Phone: ${user.phone.isEmpty ? "N/A" : user.phone}', style: const TextStyle(color: AppColors.textSecondary)),
                            Text('Role: ${user.role.toUpperCase()}', 
                              style: TextStyle(
                                color: user.role == 'admin' ? AppColors.accent : AppColors.textSecondary,
                                fontWeight: user.role == 'admin' ? FontWeight.bold : FontWeight.normal,
                              )
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline, color: AppColors.accent),
                          onPressed: () {
                            // Can show more details or edit role in the future
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('User ID: ${user.id}')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
