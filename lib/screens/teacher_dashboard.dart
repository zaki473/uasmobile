import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uasmobile/screens/teacher_announcement.dart';
import '../providers/auth_provider.dart';
import 'view_schedules.dart';
import 'input_grade.dart';
import 'login_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  // --- STYLE CONSTANTS (Ruangguru Palette) ---
  final Color rgPrimary = const Color(0xFF3ecfde); // Cyan
  final Color rgDark = const Color(0xFF00A8E8);    // Biru Langit
  final Color bgColor = const Color(0xFFFAFAFA);   // Putih Bersih
  final Color textDark = const Color(0xFF2D3E50);  // Abu Gelap

  // 2. Daftar menu (Materi Ajar DIHAPUS, Ikon DIPERCANTIK)
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Input Nilai',
      'subtitle': 'Entry nilai siswa',
      'icon': Icons.playlist_add_check_circle_rounded, // Ikon checklist nilai
      'color': Color(0xFF29B6F6), // Light Blue
      'page': const InputGrade(),
    },
    {
      'title': 'Jadwal Mengajar',
      'subtitle': 'Agenda kelas Anda',
      'icon': Icons.date_range_rounded, // Ikon kalender modern
      'color': Color(0xFFAB47BC), // Purple
      'page': ViewSchedulePage(),
    },
    {
      'title': 'Info Sekolah',
      'subtitle': 'Papan pengumuman',
      'icon': Icons.campaign_rounded, // Ikon megaphone
      'color': Color(0xFFFFA726), // Orange
      'page': const TeacherAnnouncement(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (Warna Cyan/Biru)
            _buildFancyHeader(context),
            
            const SizedBox(height: 20),

            // INFO BANNER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInfoBanner(),
            ),

            const SizedBox(height: 25),

            // TITLE SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Menu Utama",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // GRID MENU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6, // Rasio kartu persegi panjang
                ),
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return _AnimatedGridItem(
                    index: index,
                    child: _buildCompactCard(context, item),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER (Cyan Gradient) ---
  Widget _buildFancyHeader(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userName = auth.currentUser?.name ?? 'Guru';

    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [rgPrimary, rgDark], // Cyan ke Biru
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
          top: -30, right: -30,
          child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1)),
        ),
        Positioned(
          bottom: 20, left: -20,
          child: CircleAvatar(radius: 50, backgroundColor: Colors.white.withOpacity(0.1)),
        ),
        
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chip Role
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text("Pengajar", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    // Logout
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
                Text(
                  'Halo, Semangat Pagi!',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- INFO BANNER ---
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Colors.indigo, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Reminder Nilai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("Segera input nilai UAS sebelum tgl 25.", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- COMPACT CARD ---
  Widget _buildCompactCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['page'])),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'], color: item['color'], size: 24),
                    ),
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle)),
                  ],
                ),
                
                const Spacer(),
                
                // Content Text
                Text(
                  item['title'],
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark, height: 1.1),
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'],
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- ANIMASI ITEM ---
class _AnimatedGridItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedGridItem({required this.index, required this.child});
  @override
  State<_AnimatedGridItem> createState() => _AnimatedGridItemState();
}

class _AnimatedGridItemState extends State<_AnimatedGridItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: ScaleTransition(scale: _animation, child: widget.child));
  }
}