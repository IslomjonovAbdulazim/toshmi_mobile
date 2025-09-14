import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../services/file_service.dart';
import '../../../services/auth_service.dart';
import '../../constants/api_constants.dart';

class AvatarUploadWidget extends StatefulWidget {
  final String? avatarUrl;
  final int? legacyProfileImageId; // For backward compatibility
  final double size;
  final Function(String storageUrl)? onAvatarUploaded;
  final bool isEditable;

  const AvatarUploadWidget({
    Key? key,
    this.avatarUrl,
    this.legacyProfileImageId,
    this.size = 100,
    this.onAvatarUploaded,
    this.isEditable = true,
  }) : super(key: key);

  @override
  State<AvatarUploadWidget> createState() => _AvatarUploadWidgetState();
}

class _AvatarUploadWidgetState extends State<AvatarUploadWidget> {
  final FileService _fileService = Get.find<FileService>();
  final AuthService _authService = Get.find<AuthService>();
  
  bool isUploading = false;
  String? uploadedAvatarUrl;

  @override
  void initState() {
    super.initState();
    
    // Priority: New avatar_url > Legacy profile_image_id
    if (widget.avatarUrl != null) {
      uploadedAvatarUrl = widget.avatarUrl;
      print('🖼️ Avatar widget initialized with avatar URL: $uploadedAvatarUrl');
    } else if (widget.legacyProfileImageId != null) {
      uploadedAvatarUrl = '/files/${widget.legacyProfileImageId}';
      print('🖼️ Avatar widget initialized with legacy profile image ID: ${widget.legacyProfileImageId} → $uploadedAvatarUrl');
    } else {
      print('🖼️ Avatar widget initialized with no avatar');
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      setState(() => isUploading = true);

      // Check permissions
      if (source == ImageSource.camera) {
        final hasPermission = await _fileService.requestCameraPermission();
        if (!hasPermission) {
          Get.snackbar(
            'Xatolik',
            'Kamera ruxsati kerak',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
          return;
        }
      } else {
        final hasPermission = await _fileService.requestStoragePermission();
        if (!hasPermission) {
          Get.snackbar(
            'Xatolik',
            'Xotira ruxsati kerak',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
          return;
        }
      }

      // Pick image
      final imageFile = await _fileService.pickImage(source: source);
      if (imageFile == null) return;

      // Upload avatar
      final response = await _fileService.uploadUserAvatar(imageFile);
      print('📤 Avatar upload response: $response');
      
      if (response['storage_url'] != null) {
        setState(() {
          uploadedAvatarUrl = response['storage_url'];
        });
        
        print('✅ Avatar uploaded successfully! New URL: ${response['storage_url']}');
        print('📁 Filename: ${response['filename']}');

        // Update user's avatar URL in auth service  
        await _authService.updateAvatarUrl(response['storage_url']);

        // Notify parent widget
        widget.onAvatarUploaded?.call(response['storage_url']);

        Get.snackbar(
          'Muvaffaqiyat',
          'Avatar rasmi yangilandi',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      }
    } catch (e) {
      print('Avatar upload error: $e');
      Get.snackbar(
        'Xatolik',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _showImageSourceBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Rasm tanlash',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                _pickAndUploadAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
              title: const Text('Galereya'),
              onTap: () {
                Get.back();
                _pickAndUploadAvatar(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String? _getFullAvatarUrl() {
    if (uploadedAvatarUrl == null) {
      print('🚫 No avatar URL available');
      return null;
    }
    
    final fullUrl = uploadedAvatarUrl!.startsWith('http') 
        ? uploadedAvatarUrl 
        : '${ApiConstants.baseUrl}$uploadedAvatarUrl';
    
    print('🔗 Full avatar URL: $fullUrl');
    return fullUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: _getFullAvatarUrl() != null
                ? Image.network(
                    _getFullAvatarUrl()!,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingAvatar();
                    },
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        if (widget.isEditable)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: isUploading ? null : _showImageSourceBottomSheet,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    final user = _authService.currentUser;
    final initials = user != null
        ? '${user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : ''}'
            '${user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : ''}'
        : 'U';

    return Container(
      width: widget.size,
      height: widget.size,
      color: AppColors.primaryBlue.withOpacity(0.1),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: widget.size * 0.4,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}