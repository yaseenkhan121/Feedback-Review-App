import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../models/user_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalStorageService _localStorageService = LocalStorageService();

  /// Real-time Profile Stream listener for a user document `users/{uid}`
  Stream<UserModel?> getProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().asyncMap((doc) async {
      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromMap(doc.data()!, uid);
        final localPath = await _localStorageService.getProfileImagePath(uid);
        if (localPath != null && localPath.isNotEmpty) {
          return user.copyWith(photoUrl: localPath);
        }
        return user;
      }
      return null;
    });
  }

  /// Updates profile name & saves profile image to local device storage and Firestore
  Future<UserModel> updateProfile({
    required String uid,
    required String name,
    File? newImageFile,
  }) async {
    try {
      String? localPhotoPath;

      // 1. Save cropped image to device local storage ApplicationDocumentsDirectory/profile/profile_{uid}.jpg
      if (newImageFile != null) {
        localPhotoPath = await _localStorageService.saveProfileImage(
          uid: uid,
          sourceImageFile: newImageFile,
        );
      }

      final updates = <String, dynamic>{
        'name': name.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (localPhotoPath != null) {
        updates['photoUrl'] = localPhotoPath;
        updates['profilePhoto'] = localPhotoPath;
      }

      // 2. Update Firestore document
      final docRef = _firestore.collection('users').doc(uid);
      await docRef.update(updates);

      // 3. Update Firebase Auth display name
      await _auth.currentUser?.updateDisplayName(name.trim());

      // 4. Return updated user model
      final updatedDoc = await docRef.get();
      var user = UserModel.fromMap(updatedDoc.data()!, uid);
      if (localPhotoPath != null) {
        user = user.copyWith(photoUrl: localPhotoPath);
      }
      return user;
    } on FirebaseException catch (e) {
      throw Exception('Firestore update error: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// Deletes local profile image and removes stored path
  Future<void> removeProfilePhoto({
    required String uid,
  }) async {
    try {
      await _localStorageService.removeProfileImage(uid);

      final docRef = _firestore.collection('users').doc(uid);
      await docRef.update({
        'photoUrl': '',
        'profilePhoto': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove profile photo: ${e.toString()}');
    }
  }
}
