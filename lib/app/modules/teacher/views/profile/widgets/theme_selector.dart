import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../services/theme_service.dart';
import '../../../controllers/profile_controller.dart';

class ThemeSelector extends GetView<ProfileController> {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeService = ThemeService();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'theme'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
              children: [
                _buildThemeOption(
                  ThemeMode.system,
                  themeService,
                  theme,
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  ThemeMode.light,
                  themeService,
                  theme,
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  ThemeMode.dark,
                  themeService,
                  theme,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
      ThemeMode themeMode,
      ThemeService themeService,
      ThemeData theme,
      ) {
    final isSelected = controller.currentThemeMode.value == themeMode;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          themeService.getThemeModeIcon(themeMode),
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          themeService.getThemeModeText(themeMode),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(
          Icons.check_circle,
          color: theme.colorScheme.primary,
        )
            : null,
        onTap: () => controller.changeTheme(themeMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}