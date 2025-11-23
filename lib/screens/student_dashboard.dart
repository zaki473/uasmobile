import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  // Palette Warna Ruangguru Style
  final Color rgPrimary = const Color(0xFF3ecfde);
  final Color rgDark = const Color(0xFF00A8E8);
  final Color bgColor = const Color(0xFFFAFAFA);
  final Color textDark = const Color(0xFF2D3E50);

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Jadwal Pelajaran',
      'subtitle': 'Cek kelas hari ini',
      'icon': Icons.calendar_month_rounded,
      'color': Color(0xFF4FC3F7),
      'page': StudentViewSchedulePage(),
    },
    {
      'title': 'Lihat Rapor',
      'subtitle': 'Nilai & Absensi',
      'icon': Icons.pie_chart_rounded,
      'color': Color(0xFFFFA726),
      'page': const ReportCard(),
    },
    {
      'title': 'Materi Belajar',
      'subtitle': 'Bahan ajar guru',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF66BB6A),
      'page': Scaffold(
        appBar: AppBar(title: const Text('Materi Belajar')),
        body: const Center(child: Text('Halaman Materi Belajar')),
      ),
    },
    {
      'title': 'Tugas Rumah',
      'subtitle': 'Deadlinemu',
      'icon': Icons.assignment_rounded,
      'color': Color(0xFFAB47BC),
      'page': Scaffold(
          appBar: AppBar(title: Text("Tugas")), 
          body: Center(child: Text("Fitur Segera Hadir"))),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userName = auth.currentUser?.name ?? 'Siswa';

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            _buildFancyHeader(context, userName, auth),

            const SizedBox(height: 20),

            // INFO BANNER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInfoBanner(),
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
                  color: textDark,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // GRID MENU (COMPACT VERSION)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 12, // Jarak antar kartu horizontal
                  mainAxisSpacing: 12,  // Jarak antar kartu vertikal
                  childAspectRatio: 1.6, // <--- KUNCI: Angka lebih besar = Kartu lebih pendek (Ceper)
                ),
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return _AnimatedListItem(
                    index: index,
                    child: _buildCompactGridCard(context, item),
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
  Widget _buildFancyHeader(BuildContext context, String name, AuthProvider auth) {
    return Stack(
      children: [
        Container(
          height: 200, // Sedikit dikurangi tingginya biar proporsional
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [rgPrimary, rgDark],
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
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[200],
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
                Text("Halo, Semangat Pagi!", style: TextStyle(color: Colors.white70, fontSize: 14)),
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
                const Text("Pengumuman", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("Ujian Semester dimulai tgl 20.", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- NEW COMPACT CARD DESIGN ---
  Widget _buildCompactGridCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Sudut tetap rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Shadow sangat halus
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
            padding: const EdgeInsets.all(12.0), // Padding lebih kecil (Compact)
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertikal
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
                      child: Icon(item['icon'], color: item['color'], size: 22), // Icon size lebih kecil dikit
                    ),
                    // Dekorasi titik kecil di pojok kanan (opsional aesthetic)
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                    )
                  ],
                ),
                
                const Spacer(), // Dorong teks ke bawah
                
                // Teks Judul
                Text(
                  item['title'],
                  style: TextStyle(
                    fontSize: 14, // Font size pas
                    fontWeight: FontWeight.w700,
                    color: textDark,
                    height: 1.2,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                // Teks Subtitle
                Text(
                  item['subtitle'],
                  style: TextStyle(
                    fontSize: 10, // Subtitle kecil tapi terbaca
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

// --- ANIMASI (TETAP SAMA) ---
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