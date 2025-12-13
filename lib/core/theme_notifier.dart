// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ThemeNotifier extends ChangeNotifier {
//   final String key = "darkMode";
//   SharedPreferences? _prefs;
//   bool _isDarkMode = false;
//
//   bool get isDarkMode => _isDarkMode;
//
//   ThemeNotifier() {
//     _loadFromPrefs();
//   }
//
//   toggleTheme() {
//     _isDarkMode = !_isDarkMode;
//     _saveToPrefs();
//     notifyListeners();
//   }
//
//   _initPrefs() async {
//     _prefs ??= await SharedPreferences.getInstance();
//   }
//
//   _loadFromPrefs() async {
//     await _initPrefs();
//     _isDarkMode = _prefs?.getBool(key) ?? false;
//     notifyListeners();
//   }
//
//   _saveToPrefs() async {
//     await _initPrefs();
//     _prefs?.setBool(key, _isDarkMode);
//   }
// }
