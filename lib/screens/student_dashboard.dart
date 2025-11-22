import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'report_card.dart';
import 'login_screen.dart';

// Ubah menjadi StatefulWidget untuk mengelola animasi
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  // Daftar menu untuk kemudahan pengelolaan
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Lihat Rapor',
      'subtitle': 'Periksa nilai dan absensi',
      'icon': Icons.assessment_outlined,
      'color': Colors.blue,
      'page': const ReportCard(),
    },
    {
      'title': 'Jadwal Pelajaran',
      'subtitle': 'Lihat jadwal kelas harian',
      'icon': Icons.calendar_today_outlined,
      'color': Colors.teal,
      'page': Scaffold(
        appBar: AppBar(title: const Text('Jadwal Pelajaran')),
        body: const Center(child: Text('Halaman Jadwal Pelajaran')),
      ),
    },
    {
      'title': 'Materi Belajar',
      'subtitle': 'Unduh materi dari guru',
      'icon': Icons.book_outlined,
      'color': Colors.orange,
      'page': Scaffold(
        appBar: AppBar(title: const Text('Materi Belajar')),
        body: const Center(child: Text('Halaman Materi Belajar')),
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            // Menggunakan ListView.builder untuk daftar menu
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                // Terapkan animasi pada setiap item
                return _AnimatedListItem(
                  index: index,
                  child: _menuCard(
                    context: context,
                    title: item['title'],
                    subtitle: item['subtitle'],
                    icon: item['icon'],
                    color: item['color'],
                    page: item['page'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Asumsi: currentUser memiliki properti 'name'. Ganti jika perlu.
    final userName = auth.currentUser?.name ?? 'Siswa';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
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
              icon: const Icon(Icons.logout, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ikon dengan latar belakang
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              // Judul dan Subjudul
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Ikon panah
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget terpisah untuk menangani animasi setiap item list
class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Animasi diberi sedikit delay berdasarkan posisinya di list
    final delay = Duration(milliseconds: widget.index * 100);
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}