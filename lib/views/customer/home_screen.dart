import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../models/product_model.dart';
import 'product_list_screen.dart';

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
    // Không cần authViewModel ở đây nữa vì đã dùng Consumer

    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthViewModel>(
          builder: (context, authVM, _) {
            final user = authVM.currentUser;
            final address = user?.address.isNotEmpty == true ? user!.address : 'Set your location';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Location',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          // Cart Icon
          Consumer<CartViewModel>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary, size: 28),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Custom Notification Bell Icon
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          return Drawer(
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
                      authVM.currentUser?.avatarUrl.isNotEmpty == true
                          ? CircleAvatar(
                              radius: 30,
                              backgroundImage: CachedNetworkImageProvider(authVM.currentUser!.avatarUrl),
                            )
                          : const Icon(Icons.account_circle, size: 60, color: AppColors.accent),
                      const SizedBox(height: 10),
                      Text(
                        authVM.currentUser?.name ?? 'Guest',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
                      ),
                      Text(
                        authVM.currentUser?.email ?? '',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: AppColors.accent),
                  title: const Text('My Profile', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
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
                  leading: const Icon(Icons.favorite, color: AppColors.error),
                  title: const Text('My Favorites', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/favorites');
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
                    authVM.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          );
        },
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
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, child) => Text(
                          'Hello, ${authVM.currentUser?.name ?? 'Guest'}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
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
                          hintText: 'Search for electronics, components...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: IconButton(
                                icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                                onPressed: () {
                                  ProductListScreen.showFilterBottomSheet(context, productViewModel);
                                },
                              ),
                            ),
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



              // Promo Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50), // Tech dark blue color
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Get', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                Text('20% OFF', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                Text('Arduino Kits', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
                          child: Container(
                            width: 140,
                            color: Colors.blue.withValues(alpha: 0.2), // Placeholder for kit image
                            child: const Center(child: Icon(Icons.memory, size: 60, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Featured Products title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Top Picks For You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Products Horizontal List
              productViewModel.allProducts.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('No products available.',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: productViewModel.allProducts.length > 5 ? 5 : productViewModel.allProducts.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(
                                context, productViewModel.allProducts[index]);
                          },
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // All Products Title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'All Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // All Products Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = productViewModel.products[index];
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
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Consumer<AuthViewModel>(
                                        builder: (context, authVM, _) {
                                          final isFavorite = authVM.currentUser?.favoriteProductIds.contains(product.id) ?? false;
                                          return GestureDetector(
                                            onTap: () {
                                              authVM.toggleFavorite(product.id);
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 14,
                                              child: Icon(
                                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                                color: isFavorite ? AppColors.primary : AppColors.textSecondary,
                                                size: 16,
                                              ),
                                            ),
                                          );
                                        },
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
                    childCount: productViewModel.products.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
        width: 280,
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
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
              flex: 2,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
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
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Consumer<AuthViewModel>(
                      builder: (context, authVM, _) {
                        final isFavorite = authVM.currentUser?.favoriteProductIds.contains(product.id) ?? false;
                        return GestureDetector(
                          onTap: () {
                            authVM.toggleFavorite(product.id);
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? AppColors.primary : AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.stock > 0 ? '${product.stock} in stock' : 'Out of stock', 
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                          color: product.stock > 0 ? Colors.green : Colors.red,
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            SizedBox(width: 4),
                            Text('4.9 (120)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        const Text('4.9', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_shipping, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        const Text('Free ship', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
