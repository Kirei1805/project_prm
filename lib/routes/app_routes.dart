import 'package:flutter/material.dart';
import '../views/auth/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/customer/home_screen.dart';
import '../views/customer/product_list_screen.dart';
import '../views/customer/product_detail_screen.dart';
import '../views/customer/cart_screen.dart';
import '../views/customer/checkout_screen.dart';
import '../views/customer/order_history_screen.dart';
import '../views/customer/order_detail_screen.dart';
import '../views/customer/store_location_screen.dart';
import '../views/customer/chat_screen.dart';
import '../views/customer/profile_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/product_management_screen.dart';
import '../views/admin/add_edit_product_screen.dart';
import '../views/admin/order_management_screen.dart';
import '../views/admin/user_management_screen.dart';
import '../views/admin/chat_management_screen.dart';
import '../views/customer/notifications_screen.dart';
import '../views/customer/favorites_screen.dart';

/// Centralized routing configuration for the application
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productList = '/product_list';
  static const String productDetail = '/product_detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderHistory = '/order_history';
  static const String orderDetail = '/order_detail';
  static const String storeLocation = '/store_location';
  static const String chat = '/chat';
  static const String adminDashboard = '/admin_dashboard';
  static const String adminProducts = '/admin_products';
  static const String adminAddEditProduct = '/admin_add_edit_product';
  static const String adminOrders = '/admin_orders';
  static const String adminUsers = '/admin_users';
  static const String adminChats = '/admin_chats';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String favorites = '/favorites';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case productList:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case productDetail:
        return MaterialPageRoute(
          builder: (_) => const ProductDetailScreen(),
          settings: settings,
        );
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case orderHistory:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case orderDetail:
        return MaterialPageRoute(
          builder: (_) => const OrderDetailScreen(),
          settings: settings,
        );
      case storeLocation:
        return MaterialPageRoute(builder: (_) => const StoreLocationScreen());
      case chat:
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminProducts:
        return MaterialPageRoute(builder: (_) => const ProductManagementScreen());
      case adminAddEditProduct:
        return MaterialPageRoute(
          builder: (_) => const AddEditProductScreen(),
          settings: settings,
        );
      case adminOrders:
        return MaterialPageRoute(builder: (_) => const OrderManagementScreen());
      case adminUsers:
        return MaterialPageRoute(builder: (_) => const UserManagementScreen());
      case adminChats:
        return MaterialPageRoute(builder: (_) => const ChatManagementScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
