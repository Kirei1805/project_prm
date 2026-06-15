import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    try {
      // Check if Firebase is actually initialized
      if (Firebase.apps.isEmpty) {
        throw Exception("Firebase not initialized");
      }

      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel.isAuthenticated) {
        if (authViewModel.currentUser?.role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Firebase Configuration Missing', style: TextStyle(color: AppColors.error)),
          content: const Text('The app could not connect to Firebase. Please ensure you have created a Firebase project and added the google-services.json file to android/app/.'),
          backgroundColor: AppColors.surface,
          actions: [
            TextButton(
              onPressed: () {
                // Ignore and try to go to login anyway, though it will crash on auth attempt
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('IGNORE'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.memory,
              size: 100,
              color: AppColors.accent,
            ),
            const SizedBox(height: 20),
            const Text(
              'ElectroHub',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your Electronic Components Store',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
