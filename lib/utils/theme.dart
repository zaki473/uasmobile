// lib/utils/theme.dart
import 'package:flutter/material.dart';

// Tema Terang (yang mungkin sudah Anda punya)
final appTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  // ... konfigurasi lainnya
);

// Tambahkan Tema Gelap
final darkAppTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: const Color(0xFF121212), // Warna khas dark mode
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    foregroundColor: Colors.white,
  ),
  colorScheme: const ColorScheme.dark(
    primary: Colors.blue,
    secondary: Colors.blueAccent,
  ),
  // ... sesuaikan konfigurasi teks dll
);