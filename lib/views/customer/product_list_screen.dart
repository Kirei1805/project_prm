import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context, productViewModel);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: productViewModel.searchQuery),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: productViewModel.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          productViewModel.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                productViewModel.setSearchQuery(value);
              },
            ),
          ),
        ),
      ),
      body: productViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productViewModel.products.isEmpty
              ? const Center(
                  child: Text(
                    'No products found.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: productViewModel.products.length,
                  itemBuilder: (context, index) {
                    final product = productViewModel.products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/product_detail', arguments: product);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: product.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: product.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 50, color: AppColors.textSecondary),
                                      )
                                    : Container(
                                        color: AppColors.background,
                                        width: double.infinity,
                                        child: const Icon(Icons.memory, size: 50, color: AppColors.textSecondary),
                                      ),
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
                ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, ProductViewModel viewModel) {
    double? tempMinPrice = viewModel.minPrice;
    double? tempMaxPrice = viewModel.maxPrice;
    List<String> tempSelectedBrands = List.from(viewModel.selectedBrands);

    final minPriceController = TextEditingController(text: tempMinPrice != null ? tempMinPrice.toInt().toString() : '');
    final maxPriceController = TextEditingController(text: tempMaxPrice != null ? tempMaxPrice.toInt().toString() : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Products',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      TextButton(
                        onPressed: () {
                          viewModel.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.surface),
                  const SizedBox(height: 16),
                  
                  // Price Filter (Text Inputs)
                  const Text('Price Range (\$)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Min Price',
                            prefixText: '\$',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (value) {
                            tempMinPrice = double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Max Price',
                            prefixText: '\$',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (value) {
                            tempMaxPrice = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Brand Filter
                  const Text('Brands', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: viewModel.availableBrands.map((brand) {
                      final isSelected = tempSelectedBrands.contains(brand);
                      return FilterChip(
                        label: Text(brand),
                        selected: isSelected,
                        selectedColor: AppColors.accent.withOpacity(0.3),
                        checkmarkColor: AppColors.accent,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.accent : AppColors.textPrimary,
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              tempSelectedBrands.add(brand);
                            } else {
                              tempSelectedBrands.remove(brand);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        viewModel.setAdvancedFilters(
                          minPrice: tempMinPrice,
                          maxPrice: tempMaxPrice,
                          brands: tempSelectedBrands.isEmpty ? null : tempSelectedBrands,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
