import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/teacher_provider.dart';
import 'providers/grade_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/theme_provider.dart'; // <-- 1. Import ini

import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/student_dashboard.dart';

import 'utils/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => GradeProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // <-- 2. Tambahkan Provider ini
      ],
      // 3. Bungkus MaterialApp dengan Consumer<ThemeProvider>
      //    agar saat tema berubah, MaterialApp di-rebuild
      child: Consumer<ThemeProvider>( 
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Sistem Informasi Akademik',
            debugShowCheckedModeBanner: false,
            
            // Konfigurasi Tema
            themeMode: themeProvider.themeMode, // Mengikuti status provider
            theme: appTheme, // Tema Terang (dari utils/theme.dart kamu)
            darkTheme: ThemeData.dark(), // Tema Gelap (bisa dicustom juga nanti)
            
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

// ... (AuthWrapper tetap sama, tidak perlu diubah)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = authProvider.user;

    if (user == null) {
      return const LoginScreen();
    }

    switch (user.role) {
      case 'admin':
        return const AdminDashboard();
      case 'guru':
        return const TeacherDashboard();
      case 'siswa':
        return const StudentDashboard();
      default:
        return const LoginScreen();
    }
  }
}