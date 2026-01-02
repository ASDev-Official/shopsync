import 'package:flutter/material.dart';
import 'package:shopsync/services/storage/shared_prefs.dart';

/// Service for managing app locale/language preferences
class LocaleService {
  static const String _localeKey = 'app_locale';

  /// Get the saved locale from SharedPreferences
  static Future<Locale?> getSavedLocale() async {
    final languageCode = await SharedPrefs.getString(_localeKey);
    if (languageCode == null) return null;

    // Handle Chinese Traditional (zh_Hant)
    if (languageCode == 'zh_Hant') {
      return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }

    return Locale(languageCode);
  }

  /// Save locale to SharedPreferences
  static Future<void> saveLocale(Locale locale) async {
    String languageCode = locale.languageCode;

    // Handle Chinese Traditional (zh_Hant)
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      languageCode = 'zh_Hant';
    }

    await SharedPrefs.setString(_localeKey, languageCode);
  }

  /// Clear saved locale (will use device default)
  static Future<void> clearLocale() async {
    await SharedPrefs.remove(_localeKey);
  }

  /// Get display name for a locale
  static String getLocaleName(Locale locale) {
    final Map<String, String> localeNames = {
      'en': 'English',
      'de': 'Deutsch',
      'es': 'Español',
      'fr': 'Français',
      'hi': 'हिंदी',
      'it': 'Italiano',
      'ja': '日本語',
      'ko': '한국어',
      'ru': 'Русский',
      'zh': '简体中文',
      'zh_Hant': '繁體中文',
    };

    String key = locale.languageCode;
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      key = 'zh_Hant';
    }

    return localeNames[key] ?? locale.languageCode;
  }
}
