import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '675177292569-sk4bm3ur9dfl02kos55l61lelor2ch17.apps.googleusercontent.com',
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Sign Up with Email and Password
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final now = DateTime.now();
      final newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
        provider: 'email',
        createdAt: now,
        lastLoginAt: now,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());
      await credential.user?.updateDisplayName(name.trim());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign In with Email and Password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();
      final now = DateTime.now();

      if (doc.exists && doc.data() != null) {
        await docRef.update({
          'lastLoginAt': Timestamp.fromDate(now),
        });
        final updatedDoc = await docRef.get();
        return UserModel.fromMap(updatedDoc.data()!, uid);
      } else {
        // Fallback user creation if Firestore document missing
        final fallbackUser = UserModel(
          uid: uid,
          name: credential.user?.displayName ?? 'User',
          email: email.trim(),
          role: 'Student',
          provider: 'email',
          createdAt: now,
          lastLoginAt: now,
        );
        await docRef.set(fallbackUser.toMap());
        return fallbackUser;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Production-Ready Google Sign-In
  Future<UserModel?> signInWithGoogle({String selectedRole = 'Student'}) async {
    try {
      // 0. Reset previous session to ensure Google Account Picker appears
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      // 1. Trigger Google Account Picker UI
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // 2. User cancelled account selection
      if (googleUser == null) {
        return null;
      }

      // 3. Obtain authentication details from Google request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 4. Create Firebase Credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Authenticate with Firebase Authentication
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to retrieve Google user credentials from Firebase.');
      }

      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();
      final now = DateTime.now();

      if (!doc.exists) {
        final newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Google User',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
          role: selectedRole,
          provider: 'google',
          createdAt: now,
          lastLoginAt: now,
        );

        await docRef.set(newUser.toMap());
        return newUser;
      } else {
        await docRef.update({
          'lastLoginAt': Timestamp.fromDate(now),
        });
        final updatedDoc = await docRef.get();
        return UserModel.fromMap(updatedDoc.data()!, user.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on PlatformException catch (e) {
      if (e.code == 'network_error' || e.message?.contains('network') == true) {
        throw Exception('Network error during Google Sign-In. Please check your internet connection.');
      } else if (e.code == 'sign_in_canceled' || e.code == '12501') {
        return null; // User cancelled account selection
      } else if (e.code == '10' || e.message?.contains('10') == true || e.code == '12500') {
        throw Exception('Google Sign-In is configured for project feedback-app-ed175 (com.feedback_app). Ensure Google Auth provider is enabled in Firebase Console.');
      } else {
        throw Exception('Google Sign-In failed: ${e.message ?? e.code}');
      }
    } on SocketException {
      throw Exception('Internet connection unavailable. Please reconnect and try again.');
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('sign_in_canceled') || msg.contains('canceled')) {
        return null;
      }
      throw Exception('Google Sign-In error: $msg');
    }
  }

  /// Sign Out from Firebase and GoogleSignIn
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  /// Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  /// User Profile Lookup
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user profile: ${e.toString()}');
    }
  }

  /// Profile Updates
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'name': name.trim(),
        'phone': phone.trim(),
      };
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
        updates['profilePhoto'] = photoUrl;
      }
      await _firestore.collection('users').doc(uid).update(updates);
      await _auth.currentUser?.updateDisplayName(name.trim());
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      case 'invalid-credential':
        return 'Invalid authentication credential.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
