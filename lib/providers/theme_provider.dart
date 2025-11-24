import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Default mode adalah Light (terang)
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Getter boolean untuk mengecek status di UI
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Memberitahu seluruh aplikasi bahwa tema berubah
  }
}