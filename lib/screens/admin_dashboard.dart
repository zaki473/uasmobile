import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uasmobile/screens/admin_announcement.dart';
import '../providers/auth_provider.dart';
import 'manage_students.dart';
import 'manage_teachers.dart';
import 'manage_schedule.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // --- STYLE CONSTANTS (Ruangguru Palette) ---
  final Color rgPrimary = const Color(0xFF3ecfde); // Cyan
  final Color rgDark = const Color(0xFF00A8E8);    // Blue
  final Color bgColor = const Color(0xFFFAFAFA);   // White clean
  final Color textDark = const Color(0xFF2D3E50);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Update Icons to Rounded for Modern Look
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Kelola\nSiswa',
      'subtitle': 'Data siswa & kelas',
      'icon': Icons.people_alt_rounded,
      'color': Colors.teal,
      'page': const ManageStudents(),
    },
    {
      'title': 'Kelola\nGuru',
      'subtitle': 'Data pengajar',
      'icon': Icons.supervisor_account_rounded,
      'color': Colors.green,
      'page': const ManageTeachers(),
    },
    {
      'title': 'Pengumuman\nSekolah',
      'subtitle': 'Broadcast info',
      'icon': Icons.campaign_rounded,
      'color': Colors.orange,
      'page': const AdminAnnouncement(),
    },
    {
      'title': 'Jadwal\nPelajaran',
      'subtitle': 'Atur jadwal KBM',
      'icon': Icons.calendar_month_rounded,
      'color': Colors.blue,
      'page': ManageSchedulePage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // Background putih bersih
      body: Column(
        children: [
          // 1. HEADER (Design yang sama dengan Siswa)
          _buildFancyHeader(context),
          
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. TITLE SECTION
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text(
                          "Menu Administrator",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),

                      // 3. GRID MENU (Compact Style)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5, // Rasio kartu compact (Landscape)
                          ),
                          itemCount: _menuItems.length,
                          itemBuilder: (context, index) {
                            final item = _menuItems[index];
                            return _buildCompactCard(
                              context: context,
                              title: item['title'],
                              subtitle: item['subtitle'],
                              icon: item['icon'],
                              color: item['color'],
                              page: item['page'],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HEADER (MATCHING STUDENT STYLE) ---
  Widget _buildFancyHeader(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Stack(
      children: [
        // Background Gradient & Shape
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [rgPrimary, rgDark], // Cyan ke Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
            boxShadow: [
              BoxShadow(
                color: rgPrimary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),

        // Dekorasi Lingkaran
        Positioned(
          top: -40, right: -40,
          child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1)),
        ),
        Positioned(
          bottom: 20, left: -20,
          child: CircleAvatar(radius: 50, backgroundColor: Colors.white.withOpacity(0.1)),
        ),

        // Konten Header
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Icon Admin & Logout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            "Administrator",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        auth.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Dashboard Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola data sekolah dengan mudah',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET CARD (COMPACT STYLE) ---
  Widget _buildCompactCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Shadow halus
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 24, color: color),
                    ),
                    // Dekorasi titik (Optional)
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Text Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    height: 1.1,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                // Text Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}