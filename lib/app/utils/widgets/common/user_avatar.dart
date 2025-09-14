import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final String? avatarUrl;
  final Color? backgroundColor;
  final bool showBorder;
  final Color? borderColor;

  const UserAvatar({
    Key? key,
    this.size = 40,
    this.avatarUrl,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor,
  }) : super(key: key);

  factory UserAvatar.fromUser({
    double size = 40,
    bool showBorder = false,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser;
    
    String? avatarUrl;
    if (user?.profileImageId != null) {
      avatarUrl = '/storage/user_photos/${user?.profileImageId}.jpg';
    }

    return UserAvatar(
      size: size,
      avatarUrl: avatarUrl,
      backgroundColor: backgroundColor,
      showBorder: showBorder,
      borderColor: borderColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.primaryBlue.withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: ClipOval(
        child: _getFullAvatarUrl() != null
            ? Image.network(
                _getFullAvatarUrl()!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(context);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingAvatar();
                },
              )
            : _buildDefaultAvatar(context),
      ),
    );
  }

  String? _getFullAvatarUrl() {
    if (avatarUrl == null) {
      print('👤 UserAvatar: No avatar URL provided');
      return null;
    }
    
    final fullUrl = avatarUrl!.startsWith('http') 
        ? avatarUrl 
        : '${ApiConstants.baseUrl}$avatarUrl';
    
    print('👤 UserAvatar: Full URL constructed: $fullUrl');
    return fullUrl;
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser;
    final initials = user != null
        ? '${user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : ''}'
            '${user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : ''}'
        : 'U';

    return Container(
      width: size,
      height: size,
      color: backgroundColor ?? AppColors.primaryBlue.withOpacity(0.1),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: backgroundColor != null 
                ? Colors.white 
                : AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[100],
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}