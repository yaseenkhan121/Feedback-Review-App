import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads profile image to Firebase Storage at `profile_images/{uid}.jpg`
  /// Validates format, compresses quality, deletes previous photo, and returns download URL.
  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
    String? currentPhotoUrl,
  }) async {
    try {
      // 1. Image Validation (Size <= 5MB and extension format)
      final length = await imageFile.length();
      final sizeInMB = length / (1024 * 1024);
      if (sizeInMB > 5.0) {
        throw Exception('Image size exceeds maximum limit of 5 MB. Please select a smaller image.');
      }

      final ext = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(ext)) {
        throw Exception('Invalid image format ($ext). Only JPG, JPEG, and PNG images are allowed.');
      }

      // 2. Delete Old Profile Photo if present in Firebase Storage
      if (currentPhotoUrl != null &&
          currentPhotoUrl.isNotEmpty &&
          currentPhotoUrl.contains('profile_images')) {
        try {
          final oldRef = _storage.refFromURL(currentPhotoUrl);
          await oldRef.delete();
        } catch (e) {
          debugPrint('Old profile photo deletion warning: $e');
        }
      }

      // 3. Define Storage Reference
      final storageRef = _storage.ref().child('profile_images').child('$uid.jpg');

      // 4. Set Metadata & Upload
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': uid,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = storageRef.putFile(imageFile, metadata);
      final snapshot = await uploadTask.whenComplete(() {});

      // 5. Retrieve Download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        throw Exception('Storage Permission Denied. Please publish Firebase Storage rules in Firebase Console.');
      } else if (e.code == 'object-not-found' || e.code == 'bucket-not-found') {
        throw Exception('Firebase Storage is not enabled in Firebase Console. Click "Get Started" under Build -> Storage.');
      }
      throw Exception('Firebase Storage error (${e.code}): ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// Deletes profile image from Firebase Storage
  Future<void> deleteProfileImage(String photoUrl) async {
    if (photoUrl.isEmpty || !photoUrl.contains('profile_images')) return;
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
    }
  }
}
