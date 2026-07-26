import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isUploading = false;
  String? _errorMessage;
  File? _croppedImageFile;

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  File? get croppedImageFile => _croppedImageFile;

  /// Picks image from Camera or Gallery and opens Image Cropper automatically
  Future<File?> pickAndCropImage(ImageSource source) async {
    try {
      _clearError();

      // 1. Pick Image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile == null) return null; // Cancelled picking

      final originalFile = File(pickedFile.path);

      // 2. Attempt Image Cropper (1:1 Ratio, Zoom, Move, Rotate)
      try {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 85,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Profile Picture',
              toolbarColor: AppColors.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              aspectRatioPresets: [CropAspectRatioPreset.square],
            ),
            IOSUiSettings(
              title: 'Crop Profile Picture',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
              aspectRatioPresets: [CropAspectRatioPreset.square],
            ),
          ],
        );

        _croppedImageFile = croppedFile != null ? File(croppedFile.path) : originalFile;
      } catch (e) {
        // Fallback to original image if cropper encounters platform issue
        debugPrint('Cropper warning fallback: $e');
        _croppedImageFile = originalFile;
      }

      notifyListeners();
      return _croppedImageFile;
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        _setError('Permission denied. Please enable Camera / Gallery access in system settings.');
      } else {
        _setError('Camera or Gallery unavailable: ${e.message ?? e.code}');
      }
      return null;
    } catch (e) {
      _setError('Failed to select image: ${e.toString().replaceAll('Exception: ', '')}');
      return null;
    }
  }

  /// Saves image to local storage & updates AuthProvider + Firestore live
  Future<bool> updateProfile({
    required String uid,
    required String name,
    AuthProvider? authProvider,
  }) async {
    _setUploading(true);
    _clearError();

    try {
      final UserModel updatedUser = await _profileRepository.updateProfile(
        uid: uid,
        name: name,
        newImageFile: _croppedImageFile,
      );

      _croppedImageFile = null;
      _setUploading(false);

      // Update AuthProvider so currentUser immediately has new photoUrl & name
      if (authProvider != null) {
        authProvider.updateCurrentUser(updatedUser);
      }

      notifyListeners(); // Real-time UI refresh across app
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setUploading(false);
      return false;
    }
  }

  /// Removes local profile photo and updates AuthProvider + Firestore
  Future<bool> removeProfilePhoto({
    required String uid,
    AuthProvider? authProvider,
  }) async {
    _setUploading(true);
    _clearError();

    try {
      await _profileRepository.removeProfilePhoto(uid: uid);
      _croppedImageFile = null;
      _setUploading(false);

      if (authProvider != null && authProvider.currentUser != null) {
        final resetUser = authProvider.currentUser!.copyWith(photoUrl: '');
        authProvider.updateCurrentUser(resetUser);
      }

      notifyListeners(); // Real-time UI refresh across app
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setUploading(false);
      return false;
    }
  }

  void clearCroppedImage() {
    _croppedImageFile = null;
    notifyListeners();
  }

  void _setUploading(bool val) {
    _isUploading = val;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
