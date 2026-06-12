import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user stream
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current user id
  String? get currentUserId => _auth.currentUser?.uid;

  // Sign up
  Future<UserModel?> registerWithEmailPassword(String email, String password, String name, String phone) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = credential.user;

      if (firebaseUser != null) {
        UserModel newUser = UserModel(
          id: firebaseUser.uid,
          name: name,
          email: email,
          phone: phone,
          role: 'customer', // Default role
        );

        await _firestoreService.createUser(newUser);
        return newUser;
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Sign in
  Future<UserModel?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await _firestoreService.getUser(credential.user!.uid);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> logout() async {
    await _auth.signOut();
  }
}
