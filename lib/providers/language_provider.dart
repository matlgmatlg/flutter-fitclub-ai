import 'package:flutter/material.dart';
import '../widgets/common/language_selector.dart';

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
      // TODO: Implement actual language change logic using intl or your preferred localization solution
    }
  }
} 