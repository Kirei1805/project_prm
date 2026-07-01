import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
          avatarUrl: '',
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

  Future<UserModel?> loginWithEmailPassword(String email, String password) async {
    try {
      print('--- Bắt đầu đăng nhập Firebase Auth ---');
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('--- Đăng nhập Firebase Auth thành công, UID: ${credential.user?.uid} ---');

      if (credential.user != null) {
        print('--- Bắt đầu lấy dữ liệu từ Firestore ---');
        final userModel = await _firestoreService.getUser(credential.user!.uid);
        print('--- Lấy dữ liệu Firestore thành công ---');
        return userModel;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Check if user exists in Firestore
        UserModel? existingUser = await _firestoreService.getUser(firebaseUser.uid);
        
        if (existingUser != null) {
          return existingUser;
        } else {
          // New user, save to Firestore
          UserModel newUser = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Google User',
            email: firebaseUser.email ?? '',
            phone: firebaseUser.phoneNumber ?? '',
            role: 'customer', // Default role
            avatarUrl: firebaseUser.photoURL ?? '',
          );

          await _firestoreService.createUser(newUser);
          return newUser;
        }
      }
      return null;
    } catch (e) {
      print('Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> updateAddress(String uid, String address) async {
    try {
      await _firestoreService.updateUserAddress(uid, address);
    } catch (e) {
      print('Update address error: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception("Not logged in");
      }
    } catch (e) {
      print('Update password error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> logout() async {
    await _auth.signOut();
  }
}
