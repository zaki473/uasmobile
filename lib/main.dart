import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/grade_provider.dart';
import 'providers/announcement_provider.dart';

import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/student_dashboard.dart';

import 'utils/theme.dart';
import 'firebase_options.dart'; // jika kamu pakai flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ganti jika pakai manual
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
        ChangeNotifierProvider(create: (_) => GradeProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
      ],
      child: MaterialApp(
        title: 'Sistem Informasi Akademik',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Loading state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = authProvider.user;

    // Jika belum login
    if (user == null) {
      return const LoginScreen();
    }

    // Jika sudah login, arahkan sesuai role
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
