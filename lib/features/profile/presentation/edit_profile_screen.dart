import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../auth/presentation/auth_provider.dart';
import 'profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.currentUser?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickCropAndUploadImage(
    BuildContext context,
    ImageSource source,
    String uid,
    String currentPhotoUrl,
  ) async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final croppedFile = await profileProvider.pickAndCropImage(source);
    if (croppedFile != null && mounted) {
      final success = await profileProvider.updateProfile(
        uid: uid,
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : (authProvider.currentUser?.name ?? 'User'),
        authProvider: authProvider,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (profileProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileProvider.errorMessage!),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  void _showImageSourceBottomSheet(BuildContext context, String currentPhotoUrl, String uid) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _pickCropAndUploadImage(context, ImageSource.camera, uid, currentPhotoUrl);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _pickCropAndUploadImage(context, ImageSource.gallery, uid, currentPhotoUrl);
                  },
                ),
                if (currentPhotoUrl.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    title: const Text('Remove Photo', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final ok = await profileProvider.removeProfilePhoto(
                        uid: uid,
                        authProvider: authProvider,
                      );
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile picture removed successfully')),
                        );
                      }
                    },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.close_rounded),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    final success = await profileProvider.updateProfile(
      uid: currentUser.uid,
      name: _nameController.text.trim(),
      authProvider: authProvider,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else if (profileProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileProvider.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    final user = authProvider.currentUser;
    final userEmail = user?.email ?? '';
    final userRole = user?.role ?? 'Student';
    final currentPhotoUrl = user?.photoUrl ?? '';
    final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (profileProvider.isUploading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 8),
                        Text(
                          'Saving profile image to local storage...',
                          style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                // Avatar Picker Section
                Center(
                  child: Stack(
                    children: [
                      profileProvider.croppedImageFile != null
                          ? CircleAvatar(
                              radius: 54,
                              backgroundColor: AppColors.primary,
                              child: ClipOval(
                                child: Image.file(
                                  profileProvider.croppedImageFile!,
                                  width: 108,
                                  height: 108,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : AppAvatar(
                              photoUrl: currentPhotoUrl,
                              initial: initial,
                              radius: 54,
                            ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: profileProvider.isUploading
                              ? null
                              : () => _showImageSourceBottomSheet(
                                    context,
                                    currentPhotoUrl,
                                    user?.uid ?? '',
                                  ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: profileProvider.isUploading
                      ? null
                      : () => _showImageSourceBottomSheet(
                            context,
                            currentPhotoUrl,
                            user?.uid ?? '',
                          ),
                  icon: const Icon(Icons.photo_camera_rounded, size: 18),
                  label: const Text(
                    'Change Profile Picture',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 24),

                // Editable Field: Full Name
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  validator: Validators.validateName,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                ),
                const SizedBox(height: 20),

                // Read-Only Field: Email Address
                CustomTextField(
                  label: 'Email Address (Read-only)',
                  hint: userEmail,
                  readOnly: true,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),
                const SizedBox(height: 20),

                // Read-Only Field: Account Role
                CustomTextField(
                  label: 'Account Role (Read-only)',
                  hint: '$userRole Account',
                  readOnly: true,
                  prefixIcon: Icon(
                    userRole.toLowerCase() == 'student'
                        ? Icons.school_outlined
                        : Icons.business_outlined,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 32),

                // Save Profile Button
                CustomButton(
                  text: 'Save Profile Changes',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: profileProvider.isUploading,
                  onPressed: profileProvider.isUploading ? null : _handleSaveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
