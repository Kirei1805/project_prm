import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../utils/app_colors.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: admin.searchQuery),
              decoration: InputDecoration(
                hintText: 'Search by Name or Brand...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: admin.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          admin.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                admin.setSearchQuery(value);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
        onPressed: () {
          Navigator.pushNamed(context, '/admin_add_edit_product');
        },
      ),
      body: admin.isLoading
          ? const Center(child: CircularProgressIndicator())
          : admin.filteredProducts.isEmpty
              ? const Center(child: Text('No products found', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: admin.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = admin.filteredProducts[index];
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: product.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image, color: AppColors.textSecondary),
                          ),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        subtitle: Text('Stock: ${product.stock} | Price: \$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textSecondary)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.accent),
                              onPressed: () {
                                Navigator.pushNamed(context, '/admin_add_edit_product', arguments: product);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColors.surface,
                                    title: const Text('Delete Product', style: TextStyle(color: AppColors.textPrimary)),
                                    content: const Text('Are you sure you want to delete this product?', style: TextStyle(color: AppColors.textSecondary)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          admin.deleteProduct(product.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
