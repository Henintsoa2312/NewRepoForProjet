import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Classe helper pour lister les langues supportées
class L10n {
  static final all = [
    const Locale('fr', 'FR'), // Français
    const Locale('en', 'US'), // Anglais
  ];

  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }
}

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale;

  LocaleProvider(this._locale);

  Locale get locale => _locale;

  Future<void> setLocale(Locale newLocale) async {
    if (!L10n.all.contains(newLocale)) return;

    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
  }

  static Future<LocaleProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'fr'; // Français par défaut
    return LocaleProvider(Locale(languageCode));
  }
}
