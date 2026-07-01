import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    _setLoading(true);
    try {
      final uid = _authService.currentUserId;
      if (uid != null) {
        final firestoreService = FirestoreService();
        _currentUser = await firestoreService.getUser(uid);
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _currentUser = null;
    }
    _setLoading(false);
    return _currentUser != null;
  }

  String _getFriendlyErrorMessage(String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('network-request-failed') || lowerError.contains('connection timed out')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại internet của bạn.';
    } else if (lowerError.contains('wrong-password') || 
               lowerError.contains('user-not-found') || 
               lowerError.contains('invalid-credential') || 
               lowerError.contains('invalid-email')) {
      return 'Sai email hoặc mật khẩu.';
    } else if (lowerError.contains('email-already-in-use')) {
      return 'Email này đã được sử dụng. Vui lòng chọn email khác.';
    } else if (lowerError.contains('weak-password')) {
      return 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
    } else {
      return 'Đã xảy ra lỗi. Vui lòng thử lại sau.';
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError('');
    try {
      _currentUser = await _authService.loginWithEmailPassword(email, password).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timed out. Please check your network.');
        },
      );
      _setLoading(false);
      if (_currentUser == null) {
        _setError('Sai email hoặc mật khẩu.');
      }
      return _currentUser != null;
    } catch (e) {
      _setError(_getFriendlyErrorMessage(e.toString()));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError('');
    try {
      _currentUser = await _authService.signInWithGoogle();
      _setLoading(false);
      if (_currentUser == null) {
        _setError('Đăng nhập Google bị hủy hoặc thất bại.');
      }
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _setError('Đăng nhập Google thất bại: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String phone) async {
    _setLoading(true);
    _setError('');
    try {
      _currentUser = await _authService.registerWithEmailPassword(email, password, name, phone).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timed out. Please check your network.');
        },
      );
      _setLoading(false);
      if (_currentUser == null) {
        _setError('Đăng ký thất bại. Vui lòng thử lại.');
      }
      return _currentUser != null;
    } catch (e) {
      _setError(_getFriendlyErrorMessage(e.toString()));
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _currentUser = null;
    _setLoading(false);
  }

  Future<void> updateAddress(String address) async {
    if (_currentUser == null) return;
    try {
      await _authService.updateAddress(_currentUser!.id, address);
      // Update local state
      _currentUser = _currentUser!.copyWith(address: address);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> addSavedAddress(String address) async {
    if (_currentUser == null) return;
    if (_currentUser!.savedAddresses.contains(address)) return; // Already exists
    
    try {
      final updatedList = List<String>.from(_currentUser!.savedAddresses)..add(address);
      final firestoreService = FirestoreService();
      await firestoreService.updateUserAddresses(_currentUser!.id, updatedList);
      _currentUser = _currentUser!.copyWith(savedAddresses: updatedList);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> removeSavedAddress(String address) async {
    if (_currentUser == null) return;
    
    try {
      final updatedList = List<String>.from(_currentUser!.savedAddresses)..remove(address);
      final firestoreService = FirestoreService();
      await firestoreService.updateUserAddresses(_currentUser!.id, updatedList);
      _currentUser = _currentUser!.copyWith(savedAddresses: updatedList);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> toggleFavorite(String productId) async {
    if (_currentUser == null) return;
    
    try {
      final updatedList = List<String>.from(_currentUser!.favoriteProductIds);
      if (updatedList.contains(productId)) {
        updatedList.remove(productId);
      } else {
        updatedList.add(productId);
      }
      
      final firestoreService = FirestoreService();
      await firestoreService.updateUserFavorites(_currentUser!.id, updatedList);
      _currentUser = _currentUser!.copyWith(favoriteProductIds: updatedList);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> updateProfile(String name, String phone, String avatarUrl) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _setError('');
    try {
      final firestoreService = FirestoreService();
      await firestoreService.updateUserProfile(_currentUser!.id, name, phone, avatarUrl);
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: name,
        email: _currentUser!.email,
        phone: phone,
        role: _currentUser!.role,
        address: _currentUser!.address,
        avatarUrl: avatarUrl,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getFriendlyErrorMessage(e.toString()));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    _setLoading(true);
    _setError('');
    try {
      await _authService.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('requires-recent-login')) {
        _setError('Vui lòng đăng xuất và đăng nhập lại trước khi đổi mật khẩu.');
      } else if (errorStr.contains('weak-password')) {
        _setError('Mật khẩu quá yếu (cần ít nhất 6 ký tự).');
      } else {
        _setError('Đổi mật khẩu thất bại. Thử lại sau.');
      }
      _setLoading(false);
      return false;
    }
  }
}
