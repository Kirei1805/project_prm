import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.background,
      body: Consumer2<AuthViewModel, ProductViewModel>(
        builder: (context, authVM, productVM, child) {
          final favoriteIds = authVM.currentUser?.favoriteProductIds ?? [];
          
          if (favoriteIds.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Favorites Yet',
              subtitle: 'Tap the heart icon on any product to save it here.',
              icon: Icons.favorite_border,
            );
          }

          final favoriteProducts = productVM.getProductsByIds(favoriteIds);

          if (favoriteProducts.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Favorites Yet',
              subtitle: 'Tap the heart icon on any product to save it here.',
              icon: Icons.favorite_border,
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/product_detail', arguments: product);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Hero(
                                tag: 'fav_product_image_${product.id}',
                                child: product.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: product.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 50, color: AppColors.textSecondary),
                                      )
                                    : Container(
                                        color: AppColors.background,
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: const Icon(Icons.memory, size: 50, color: AppColors.textSecondary),
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  authVM.toggleFavorite(product.id);
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 14,
                                  child: const Icon(
                                    Icons.favorite,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(product.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
