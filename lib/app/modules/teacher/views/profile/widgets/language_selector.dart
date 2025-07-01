import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../services/language_service.dart';
import '../../../controllers/profile_controller.dart';

class LanguageSelector extends GetView<ProfileController> {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageService = LanguageService();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'language'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
                  () => Column(
                children: [
                  _buildLanguageOption(
                    const Locale('uz', 'UZ'),
                    languageService,
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildLanguageOption(
                    const Locale('ru', 'RU'),
                    languageService,
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildLanguageOption(
                    const Locale('en', 'US'),
                    languageService,
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      Locale locale,
      LanguageService languageService,
      ThemeData theme,
      ) {
    final isSelected = controller.currentLocale.value == locale;

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
        leading: Text(
          languageService.getLanguageFlag(locale),
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          languageService.getLanguageText(locale),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
        onTap: () => controller.changeLanguage(locale),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}