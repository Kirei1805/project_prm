import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  
  try {
    await Firebase.initializeApp();
    
    // Bật offline persistence + cấu hình Firestore cho emulator
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
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
  // Notification init - fire and forget, không block gì cả
  Future.delayed(const Duration(seconds: 3), () async {
    try {
      final notificationService = NotificationService();
      await notificationService.init();
    } catch (e) {
      print("Notification init error: $e");
    }
  });
}

class ElectroHubApp extends StatelessWidget {
  const ElectroHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElectroHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
