import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyPrefix = 'profile_image_path_';

  /// Saves cropped image into ApplicationDocumentsDirectory/profile/profile_{uid}.jpg
  /// Validates format, size, deletes previous image, and saves path in SharedPreferences.
  Future<String> saveProfileImage({
    required String uid,
    required File sourceImageFile,
  }) async {
    try {
      // 1. Image Validation (Size <= 5 MB and Extension Format)
      final length = await sourceImageFile.length();
      final sizeInMB = length / (1024 * 1024);
      if (sizeInMB > 5.0) {
        throw Exception('Image size exceeds maximum limit of 5 MB.');
      }

      final ext = p.extension(sourceImageFile.path).replaceAll('.', '').toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(ext)) {
        throw Exception('Invalid image format ($ext). Only JPG, JPEG, and PNG are allowed.');
      }

      // 2. Ensure ApplicationDocumentsDirectory/profile/ directory exists
      final docsDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory(p.join(docsDir.path, 'profile'));
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // 3. Delete previous file if exists
      final targetPath = p.join(profileDir.path, 'profile_$uid.jpg');
      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }

      // 4. Copy image from temporary location to permanent app storage
      await sourceImageFile.copy(targetPath);

      // 5. Store image path in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyPrefix$uid', targetPath);

      debugPrint('Local profile image saved at: $targetPath');
      return targetPath;
    } catch (e) {
      if (e.toString().contains('No space left on device') || e is FileSystemException) {
        throw Exception('Storage full or permission error while saving image.');
      }
      throw Exception('Failed to save profile image: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// Loads stored profile image file path for a user
  Future<String?> getProfileImagePath(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('$_keyPrefix$uid');
      if (savedPath != null && savedPath.isNotEmpty) {
        final file = File(savedPath);
        if (await file.exists()) {
          return savedPath;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Deletes local profile image file and clears SharedPreferences path
  Future<void> removeProfileImage(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('$_keyPrefix$uid');
      if (savedPath != null && savedPath.isNotEmpty) {
        final file = File(savedPath);
        if (await file.exists()) {
          await file.delete();
        }
        await prefs.remove('$_keyPrefix$uid');
      }
    } catch (e) {
      debugPrint('Error removing local profile image: $e');
    }
  }
}
