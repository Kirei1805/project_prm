import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'routes/app_routes.dart';
import 'utils/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/product_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'viewmodels/order_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // NOTE: Firebase.initializeApp() needs configuration parameters depending on the platform.
  // We put a try-catch so the app doesn't crash if Firebase isn't configured yet.
  try {
    await Firebase.initializeApp();
    // Initialize Notification Service
    final notificationService = NotificationService();
    await notificationService.init();
  } catch (e) {
    print("Firebase initialization error (might be missing google-services.json): $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: const ElectroHubApp(),
    ),
  );
}

class ElectroHubApp extends StatelessWidget {
  const ElectroHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElectroHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Premium dark theme
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
