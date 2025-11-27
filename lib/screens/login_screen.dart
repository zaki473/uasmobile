import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'admin_dashboard.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!mounted) return;
    setState(() => isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.login(emailC.text.trim(), passC.text.trim());

    if (!mounted) return;
    setState(() => isLoading = false);

    if (ok) {
      final role = auth.currentUser!.role;
      Widget next;
      if (role == 'admin') {
        next = const AdminDashboard();
      } else if (role == 'guru') {
        next = const TeacherDashboard();
      } else {
        next = const StudentDashboard();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => next));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Gagal! Periksa kembali email dan password.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // --- PALET WARNA AKADEMIK ---
    // Light Mode: Royal Blue & White (Formal & Bersih)
    // Dark Mode: Deep Navy & Dark Grey (Nyaman di mata)
    
    final primaryColor = isDark ? const Color(0xFF90CAF9) : const Color(0xFF0D47A1); // Biru Akademik
    final accentColor = isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2); // Biru lebih muda
    final bgColorTop = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA); // Background atas (Light: Abu sangat muda)
    final bgColorBottom = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE3E8EF); // Background bawah

    final cardColor = isDark ? const Color(0xFF252525) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF263238); // Biru Gelap Hampir Hitam
    final inputFill = isDark ? const Color(0xFF303030) : const Color(0xFFF0F4F8); // Abu kebiruan sangat muda
    
    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: Background Geometris Sederhana
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgColorTop, bgColorBottom],
              ),
            ),
          ),
          // Hiasan Header (Lingkaran besar di pojok atas)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(isDark ? 0.1 : 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(isDark ? 0.1 : 0.05),
              ),
            ),
          ),

          // LAYER 2: Konten Utama
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Icon Sekolah
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_rounded, // Icon Universitas/Gedung
                      size: 50,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Teks Judul
                  Text(
                    'SIAKAD',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Sistem Informasi Akademik',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Card Form Login
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.white,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D47A1).withOpacity(0.08), // Bayangan biru tipis
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Silakan Masuk",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Gunakan akun institusi Anda",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Input Email
                        _buildInputField(
                          controller: emailC,
                          label: 'Email Institusi',
                          icon: Icons.email_outlined,
                          isDark: isDark,
                          fillColor: inputFill,
                          textColor: textColor,
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 16),

                        // Input Password
                        _buildPasswordField(
                          controller: passC,
                          isDark: isDark,
                          fillColor: inputFill,
                          textColor: textColor,
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 32),

                        // Tombol Login
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: isDark ? Colors.black87 : Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: primaryColor.withOpacity(0.4),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'MASUK DASHBOARD',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  Text(
                    "© 2025 Sekolah Tinggi Teknologi",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LAYER 3: Tombol Theme Switch (Pojok Kanan Atas Minimalis)
          Positioned(
            top: 50,
            right: 20,
            child: InkWell(
              onTap: () => themeProvider.toggleTheme(!isDark),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Input Field Biasa
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color fillColor,
    required Color textColor,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, 
          style: TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.w600, 
            color: textColor.withOpacity(0.7)
          )
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.6)),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Widget Helper untuk Password Field
  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isDark,
    required Color fillColor,
    required Color textColor,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Password", 
          style: TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.w600, 
            color: textColor.withOpacity(0.7)
          )
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !_isPasswordVisible,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline_rounded, color: primaryColor.withOpacity(0.6)),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}