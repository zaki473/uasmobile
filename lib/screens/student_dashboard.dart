import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uasmobile/screens/student_announcement.dart';
import '../providers/auth_provider.dart';
import 'student_view_schedule.dart';
import 'report_card.dart';
import 'login_screen.dart';



class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  // Palette Warna Ruangguru Style (Tetap disimpan untuk mode terang/branding)
  final Color rgPrimary = const Color(0xFF3ecfde);
  final Color rgDark = const Color(0xFF00A8E8);
  
  // Warna default mode terang
  final Color lightBgColor = const Color(0xFFFAFAFA);
  final Color lightTextDark = const Color(0xFF2D3E50);

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Jadwal Pelajaran',
      'subtitle': 'Cek kelas hari ini',
      'icon': Icons.calendar_month_rounded,
      'color': const Color(0xFF4FC3F7),
      'page': StudentViewSchedulePage(),
    },
    {
      'title': 'Lihat Rapor',
      'subtitle': 'Nilai & Absensi',
      'icon': Icons.pie_chart_rounded,
      'color': const Color(0xFFFFA726),
      'page': const ReportCard(),
    },
    {
      'title': 'Pengumuman',
      'subtitle': 'Info sekolah',
      'icon': Icons.campaign_rounded,
      'color': Colors.blue,
      'page': const StudentAnnouncement(),
    },
    {
      'title': 'Materi Belajar',
      'subtitle': 'Bahan ajar guru',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF66BB6A),
      'page': Scaffold(
        appBar: AppBar(title: const Text('Materi Belajar')),
        body: const Center(child: Text('Halaman Materi Belajar')),
      ),
    },
    {
      'title': 'Tugas Rumah',
      'subtitle': 'Deadlinemu',
      'icon': Icons.assignment_rounded,
      'color': const Color(0xFFAB47BC),
      'page': Scaffold(
          appBar: AppBar(title: const Text("Tugas")), 
          body: const Center(child: Text("Fitur Segera Hadir"))),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userName = auth.currentUser?.name ?? 'Siswa';

    // 1. Cek Mode Gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Tentukan Warna Berdasarkan Mode
    final Color currentBgColor = isDark ? const Color(0xFF121212) : lightBgColor;
    final Color currentTextColor = isDark ? Colors.white : lightTextDark;
    
    // Warna kartu: Putih di Light mode, Abu gelap di Dark mode
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white; 

    return Scaffold(
      backgroundColor: currentBgColor, // <-- Gunakan background dinamis
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (Warna gradient tetap dipertahankan karena branding)
            _buildFancyHeader(context, userName, auth, isDark),

            const SizedBox(height: 20),

            // INFO BANNER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInfoBanner(isDark, cardColor, currentTextColor),
            ),

            const SizedBox(height: 25),

            // TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Menu Utama",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: currentTextColor, // <-- Warna text dinamis
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
                  childAspectRatio: 1.6, 
                ),
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return _AnimatedListItem(
                    index: index,
                    child: _buildCompactGridCard(context, item, isDark, cardColor, currentTextColor),
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

  // --- WIDGET HEADER ---
  Widget _buildFancyHeader(BuildContext context, String name, AuthProvider auth, bool isDark) {
    return Stack(
      children: [
        Container(
          height: 200, 
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [rgPrimary, rgDark], // Gradient tetap sama biar cantik
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
        
        // Dekorasi background
        Positioned(
          top: -30, right: -30,
          child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1)),
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
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 20,
                        // Background icon profil menyesuaikan
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(Icons.person, color: rgDark, size: 20),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        auth.logout();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                const Text("Halo, Semangat Pagi!", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET BANNER ---
  Widget _buildInfoBanner(bool isDark, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor, // <-- Warna card dinamis
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Border lebih tipis/hilang di dark mode biar ga kaku
          color: isDark ? Colors.white10 : Colors.grey.shade100
        ),
        boxShadow: [
          // Shadow dikurangi saat dark mode
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pengumuman", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)
                ),
                Text(
                  "Ujian Semester dimulai tgl 20.", 
                  // Warna subtitle dinamis
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- COMPACT CARD DESIGN ---
  Widget _buildCompactGridCard(
    BuildContext context, 
    Map<String, dynamic> item, 
    bool isDark, 
    Color cardColor, 
    Color titleColor
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor, // <-- Warna card dinamis
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03), 
            spreadRadius: 0,
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
                // Icon di Kiri Atas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'], color: item['color'], size: 22), 
                    ),
                    // Titik dekorasi
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        // Warna titik menyesuaikan
                        color: isDark ? Colors.grey[700] : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                    )
                  ],
                ),
                
                const Spacer(), 
                
                // Teks Judul
                Text(
                  item['title'],
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w700,
                    color: titleColor, // <-- Warna text dinamis
                    height: 1.2,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                // Teks Subtitle
                Text(
                  item['subtitle'],
                  style: TextStyle(
                    fontSize: 10, 
                    // Warna subtitle dinamis
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
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

// --- ANIMASI (TIDAK PERLU DIUBAH) ---
class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedListItem({required this.index, required this.child});
  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }
  
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fadeAnimation, child: SlideTransition(position: _slideAnimation, child: widget.child));
  }
}