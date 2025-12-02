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
          context, MaterialPageRoute(builder: (_) => next));
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
    final size = MediaQuery.of(context).size;

    // --- COLOR PALETTE (Clean & Elegant) ---
    // Light: Putih Bersih + Biru Laut Dalam (Deep Teal)
    // Dark: Abu Arang (Charcoal) + Biru Elektrik Lembut
    final Color mainBg = isDark ? const Color(0xFF1E1E24) : const Color(0xFFFFFFFF);
    final Color secondaryBg = isDark ? const Color(0xFF2D2D35) : const Color(0xFFF8F9FD);
    final Color brandColor = isDark ? const Color(0xFF6C63FF) : const Color(0xFF2A2D3E);
    final Color textColor = isDark ? Colors.white : const Color(0xFF2A2D3E);

    return Scaffold(
      backgroundColor: secondaryBg,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            // 1. BACKGROUND HEADER (Curved Shape)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.45, // Mengambil 45% layar atas
              child: Container(
                decoration: BoxDecoration(
                  color: brandColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(60), // Lengkungan elegant
                    bottomRight: Radius.circular(60),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brandColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school_rounded, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "AKADEMIK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "Portal Sistem Informasi",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40), // Ruang agar tidak tertutup kartu
                  ],
                ),
              ),
            ),

            // 2. THEME TOGGLE (Top Right)
            Positioned(
              top: 50,
              right: 25,
              child: InkWell(
                onTap: () => themeProvider.toggleTheme(!isDark),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // 3. FLOATING FORM CARD
            Positioned(
              top: size.height * 0.35, // Muncul menumpuk di atas header
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                decoration: BoxDecoration(
                  color: mainBg,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selamat Datang",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Silakan login untuk melanjutkan.",
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // INPUT EMAIL
                    _buildElegantField(
                      controller: emailC,
                      label: "Email",
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 20),

                    // INPUT PASSWORD
                    _buildElegantField(
                      controller: passC,
                      label: "Password",
                      icon: Icons.lock_outline_rounded,
                      isDark: isDark,
                      textColor: textColor,
                      isPassword: true,
                    ),

                    const SizedBox(height: 40),

                    // BUTTON LOGIN
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor,
                          foregroundColor: Colors.white,
                          elevation: 0, // Flat design agar elegant
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Masuk",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 4. FOOTER COPYRIGHT
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "© 2024 Sekolah Digital",
                  style: TextStyle(
                    color: textColor.withOpacity(0.3),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET INPUT KHUSUS
  Widget _buildElegantField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color textColor,
    bool isPassword = false,
  }) {
    // Warna fill input yang sangat lembut
    final fillColor = isDark ? const Color(0xFF2A2A35) : const Color(0xFFF5F6FA);

    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none, // Hilangkan garis border
          labelText: label,
          labelStyle: TextStyle(color: textColor.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: textColor.withOpacity(0.4), size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: textColor.withOpacity(0.4),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}