import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String productId = '';
    ProductModel? product;

    if (args is String) {
      productId = args;
    } else if (args is ProductModel) {
      productId = args.id;
      product = args; // We have the product directly
    }

    final productViewModel = Provider.of<ProductViewModel>(context);
    
    // Find product from viewmodel if we only have ID
    if (product == null && productId.isNotEmpty) {
      try {
        product = productViewModel.products.firstWhere((p) => p.id == productId);
      } catch (e) {
        product = null;
      }
    }

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Hero(
                tag: 'product_image_${product.id}',
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 100, color: AppColors.textSecondary),
                      )
                    : Container(
                        color: AppColors.background,
                        child: const Icon(Icons.memory, size: 100, color: AppColors.textSecondary),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(product.price),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Brand: ${product.brand} | SKU: ${product.sku}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Technical Specifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSpecRow('Voltage', product.voltage),
                  _buildSpecRow('Stock', product.stock > 0 ? '${product.stock} available' : 'Out of Stock'),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: product.stock > 0
                        ? () {
                            Provider.of<CartViewModel>(context, listen: false).addItem(product!);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('${product.name} added to cart!'),
                                action: SnackBarAction(
                                  label: 'VIEW CART',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    Navigator.pushNamed(context, '/cart');
                                  },
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(product.stock > 0 ? 'ADD TO CART' : 'OUT OF STOCK'),
                  ),
                  const SizedBox(height: 40),
                  _buildRecommendations(context, product, productViewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, ProductModel currentProduct, ProductViewModel viewModel) {
    final recommendations = viewModel.getRecommendations(currentProduct.id, currentProduct.categoryId);
    
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You might also like',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final product = recommendations[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/product_detail',
                        arguments: product.id,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              color: Colors.grey[200],
                            ),
                            child: product.imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                                  )
                                : const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(product.price),
                                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
