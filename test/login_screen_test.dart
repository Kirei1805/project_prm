import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project_prm/views/auth/login_screen.dart';
import 'package:project_prm/viewmodels/auth_viewmodel.dart';

import 'package:project_prm/models/user_model.dart';

// Mock AuthViewModel for testing
class MockAuthViewModel extends ChangeNotifier implements AuthViewModel {
  @override
  bool get isLoading => false;

  @override
  String get errorMessage => '';

  @override
  UserModel? get currentUser => null;

  @override
  bool get isAuthenticated => false;

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<bool> register(String email, String password, String name, String phone) async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<void> updateAddress(String address) async {}

  @override
  Future<bool> updateProfile(String name, String phone, String avatarUrl) async => true;

  @override
  Future<bool> changePassword(String newPassword) async => true;
}

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(create: (_) => MockAuthViewModel()),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify title is present
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue to ElectroHub'), findsOneWidget);

    // Verify text fields are present
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify buttons are present
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Don\'t have an account? Register'), findsOneWidget);
  });

  testWidgets('LoginScreen validates empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap login button without entering data
    final loginButton = find.byKey(const Key('loginButton'));
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();
    
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Verify validation errors appear
    expect(find.text('Email cannot be empty'), findsOneWidget);
    expect(find.text('Password cannot be empty'), findsOneWidget);
  });
}
