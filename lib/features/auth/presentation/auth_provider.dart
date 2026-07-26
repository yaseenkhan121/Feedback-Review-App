import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/user_model.dart';
import '../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initAuthListener();
  }

  /// Updates local cached user model (e.g. after profile/avatar updates)
  void updateCurrentUser(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  /// Listen to Firebase Auth state changes for automatic session persistence
  void _initAuthListener() {
    _authRepository.authStateChanges.listen((User? user) async {
      if (user == null) {
        _currentUser = null;
        _isInitialized = true;
        notifyListeners();
      } else {
        try {
          UserModel? profile = await _authRepository.getUserProfile(user.uid);
          if (profile == null) {
            // Fallback profile if Firestore doc missing
            profile = UserModel(
              uid: user.uid,
              name: user.displayName?.isNotEmpty == true ? user.displayName! : 'User',
              email: user.email ?? '',
              role: 'Student',
              photoUrl: user.photoURL ?? '',
              provider: user.providerData.any((p) => p.providerId == 'google.com') ? 'google' : 'email',
              createdAt: DateTime.now(),
              lastLoginAt: DateTime.now(),
            );
          }
          _currentUser = profile;
        } catch (_) {
          // If device offline on app start, retain user session from Firebase Auth local persistence
          _currentUser = UserModel(
            uid: user.uid,
            name: user.displayName?.isNotEmpty == true ? user.displayName! : 'User',
            email: user.email ?? '',
            role: 'Student',
            photoUrl: user.photoURL ?? '',
            provider: user.providerData.any((p) => p.providerId == 'google.com') ? 'google' : 'email',
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
        } finally {
          _isInitialized = true;
          notifyListeners();
        }
      }
    });
  }

  /// Sign Up with Email and Password
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Login with Email and Password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Google Sign-In Method
  Future<bool> signInWithGoogle({String selectedRole = 'Student'}) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authRepository.signInWithGoogle(selectedRole: selectedRole);
      _setLoading(false);

      if (user == null) {
        // User cancelled account picker
        return false;
      }

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Manual Logout - Only called when user explicitly taps Logout button
  Future<void> logout() async {
    _setLoading(true);
    await _authRepository.signOut(); // Clears Firebase session & GoogleSignIn session
    _currentUser = null;
    _setLoading(false);
  }

  /// Reset Password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Profile Update
  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.updateUserProfile(
        uid: _currentUser!.uid,
        name: name,
        phone: phone,
      );
      _currentUser = _currentUser!.copyWith(
        name: name.trim(),
        phone: phone.trim(),
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
