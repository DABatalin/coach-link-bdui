import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage {
  russian('ru', 'Русский'),
  english('en', 'English');

  final String code;
  final String name;

  const AppLanguage(this.code, this.name);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.russian,
    );
  }
}

class LanguageService {
  Future<void> setLanguage(AppLanguage language, BuildContext context) async {
    await context.setLocale(Locale(language.code));
  }

  AppLanguage getCurrentLanguage(BuildContext context) {
    final locale = EasyLocalization.of(context)!.locale;
    return AppLanguage.fromCode(locale.languageCode);
  }

  List<AppLanguage> getSupportedLanguages() {
    return AppLanguage.values;
  }
}

// Provider для LanguageService
final languageServiceProvider = Provider<LanguageService>((ref) {
  return LanguageService();
});
