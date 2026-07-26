import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProfileImageService {
  static const String _keyPrefix = 'user_profile_photo_';

  /// Saves cropped image file to device persistent local app directory
  Future<String> saveProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final targetPath = '${appDir.path}/profile_avatar_$uid.jpg';

      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }

      await imageFile.copy(targetPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyPrefix$uid', targetPath);

      debugPrint('Profile image saved locally at: $targetPath');
      return targetPath;
    } catch (e) {
      throw Exception('Failed to save profile image locally: ${e.toString()}');
    }
  }

  /// Retrieves local saved profile image file path if it exists
  Future<String?> getProfileImagePath(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('$_keyPrefix$uid');
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          return path;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Removes local profile image file
  Future<void> removeProfileImage(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('$_keyPrefix$uid');
      if (path != null && path.isNotEmpty) {
        final file = File(path);
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
