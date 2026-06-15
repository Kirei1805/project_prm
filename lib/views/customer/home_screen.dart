import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dùng Future() để schedule ra ngoài frame hiện tại - UI render trước, streams khởi động sau
    Future(() {
      if (mounted) {
        Provider.of<ProductViewModel>(context, listen: false).initIfNeeded();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // listen: false vì authViewModel không thay đổi trong màn hình này
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ElectroHub', style: TextStyle(color: AppColors.accent)),
        actions: [
          // Consumer giới hạn rebuild chỉ badge giỏ hàng
          Consumer<CartViewModel>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.account_circle, size: 60, color: AppColors.accent),
                  const SizedBox(height: 10),
                  Text(
                    authViewModel.currentUser?.name ?? 'Guest',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
                  ),
                  Text(
                    authViewModel.currentUser?.email ?? '',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.textPrimary),
              title: const Text('Order History', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/order_history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.accent),
              title: const Text('Store Location', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/store_location');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: AppColors.accent),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppColors.accent),
              title: const Text('Support Chat', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () {
                authViewModel.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      // Dùng Consumer chỉ để rebuild phần body khi productViewModel thay đổi
      body: Consumer<ProductViewModel>(
        builder: (context, productViewModel, _) {
          if (productViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          // Dùng CustomScrollView + Sliver để tránh shrinkWrap
          return CustomScrollView(
            slivers: [
              // Header: Welcome + Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${authViewModel.currentUser?.name ?? 'Guest'}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'What are you looking for today?',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for components...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_forward, color: AppColors.accent),
                            onPressed: () {
                              Navigator.pushNamed(context, '/product_list');
                            },
                          ),
                        ),
                        onChanged: (value) {
                          productViewModel.setSearchQuery(value);
                        },
                        onSubmitted: (_) {
                          Navigator.pushNamed(context, '/product_list');
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Smart Recommendations (chỉ hiện khi search 'irrigation')
              if (productViewModel.searchQuery.toLowerCase().contains('irrigation')) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Smart Recommendations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      itemCount: productViewModel.recommendedProducts.length,
                      itemBuilder: (context, index) {
                        return _buildHorizontalProductCard(
                            context, productViewModel.recommendedProducts[index]);
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],

              // Categories title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Categories Grid — dùng SliverGrid thay vì shrinkWrap GridView
              productViewModel.categories.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('No categories found.',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.5,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = productViewModel.categories[index];
                            return GestureDetector(
                              onTap: () {
                                productViewModel.setCategoryFilter(category.id);
                                Navigator.pushNamed(context, '/product_list');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: productViewModel.categories.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Featured Products title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Products Grid — SliverGrid với lazy rendering tự động
              productViewModel.products.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('No products available.',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildProductCard(
                                context, productViewModel.products[index]);
                          },
                          childCount: productViewModel.products.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHorizontalProductCard(BuildContext context, ProductModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product_detail', arguments: product);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: AppColors.textSecondary),
                      )
                    : Container(
                        color: AppColors.background,
                        width: double.infinity,
                        child: const Icon(Icons.memory,
                            size: 40, color: AppColors.textSecondary),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
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
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: AppColors.textSecondary),
                      )
                    : Container(
                        color: AppColors.background,
                        width: double.infinity,
                        child: const Icon(Icons.memory,
                            size: 50, color: AppColors.textSecondary),
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
  }
}
