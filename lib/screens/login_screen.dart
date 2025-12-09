import 'dart:ui'; // Diperlukan untuk efek Glassmorphism (Blur)
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
  // --- LOGIC AUTH (TIDAK DIUBAH SAMA SEKALI) ---
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
        context,
        MaterialPageRoute(builder: (_) => next),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Gagal. Cek email dan password.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  // --- END LOGIC ---

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Palette Ruangguru Style (Modern & Vibrant)
    final Color bgGradientTop = isDark ? const Color(0xFF0F2027) : const Color(0xFFE0F7FA);
    final Color bgGradientBottom = isDark ? const Color(0xFF2C5364) : const Color(0xFFF0F4F8);
    
    final Color accentCyan = const Color(0xFF00C4FF); // Ruangguru Blue/Cyan
    final Color accentOrange = const Color(0xFFFFA000); // Ruangguru Orange
    
    final Color glassColor = isDark 
        ? Colors.black.withOpacity(0.4) 
        : Colors.white.withOpacity(0.7);
        
    final Color textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. BACKGROUND DINAMIS (Gradient + Abstract Shapes)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgGradientTop, bgGradientBottom],
              ),
            ),
          ),
          
          // Bubble Dekorasi 1 (Pojok Kiri Atas - Cyan)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentCyan.withOpacity(0.4),
                boxShadow: [BoxShadow(color: accentCyan.withOpacity(0.5), blurRadius: 60)],
              ),
            ),
          ),

          // Bubble Dekorasi 2 (Tengah Kanan - Orange)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentOrange.withOpacity(isDark ? 0.2 : 0.3),
                boxShadow: [BoxShadow(color: accentOrange.withOpacity(0.4), blurRadius: 80)],
              ),
            ),
          ),

           // Bubble Dekorasi 3 (Bawah Kiri - Ungu tipis)
          Positioned(
            bottom: -40,
            left: 20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.3),
                boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 50)],
              ),
            ),
          ),

          // 2. KONTEN UTAMA (GLASSMORPHISM CARD)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Logo Icon Floating
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(Icons.school_rounded, size: 40, color: accentCyan),
                  ),

                  // Kartu Kaca (Glass Card)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: glassColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(isDark ? 0.1 : 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Welcome Back!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Learning Management System",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 32),

                            _buildModernInput(
                              controller: emailC,
                              icon: Icons.alternate_email_rounded,
                              hint: "Email",
                              isDark: isDark,
                              accent: accentCyan,
                              textColor: textColor,
                            ),
                            const SizedBox(height: 20),
                            _buildModernInput(
                              controller: passC,
                              icon: Icons.lock_outline_rounded,
                              hint: "Password",
                              isDark: isDark,
                              accent: accentCyan,
                              isPassword: true,
                              textColor: textColor,
                            ),
                            
                            const SizedBox(height: 40),

                            // Gradient Button
                            Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [accentCyan, Colors.blueAccent],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentCyan.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24, 
                                        height: 24, 
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Masuk Akun",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20)
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  Text(
                    "Sistem Akademik Digital",
                    style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. THEME SWITCHER (Top Right - Minimalist)
          Positioned(
            top: 50,
            right: 24,
            child: GestureDetector(
              onTap: () => themeProvider.toggleTheme(!isDark),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Icon(
                  isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: isDark ? Colors.yellow : Colors.indigo,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Input yang lebih modern (Tanpa border kasar)
  Widget _buildModernInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool isDark,
    required Color accent,
    required Color textColor,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: accent.withOpacity(0.8)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: textColor.withOpacity(0.4),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}