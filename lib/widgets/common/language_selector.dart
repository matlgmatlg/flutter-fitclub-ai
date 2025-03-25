import 'package:flutter/material.dart';
import '../../core/theme.dart';

enum AppLanguage {
  english('English', 'en'),
  portuguese('Português', 'pt'),
  spanish('Español', 'es');

  final String label;
  final String code;
  const AppLanguage(this.label, this.code);
}

class LanguageSelector extends StatelessWidget {
  final AppLanguage currentLanguage;
  final Function(AppLanguage) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLanguage>(
      tooltip: 'Select language',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      position: PopupMenuPosition.under,
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 20),
            const SizedBox(width: 8),
            Text(
              currentLanguage.code.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => AppLanguage.values.map((language) {
        return PopupMenuItem<AppLanguage>(
          value: language,
          child: Row(
            children: [
              if (language == currentLanguage)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.check, size: 18),
                ),
              Text(
                language.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: language == currentLanguage
                          ? AppTheme.primaryColor
                          : AppTheme.primaryTextColor,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
      onSelected: onLanguageChanged,
    );
  }
} 