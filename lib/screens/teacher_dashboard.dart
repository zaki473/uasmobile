import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'view_schedules.dart';
import 'input_grade.dart';
import 'login_screen.dart';

// 1. Ubah menjadi StatefulWidget untuk mengelola animasi
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  // 2. Daftar menu untuk kemudahan pengelolaan
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Input Nilai',
      'subtitle': 'Masukkan nilai siswa',
      'icon': Icons.edit_note_outlined,
      'color': Colors.green,
      'page': const InputGrade(),
    },
    {
      'title': 'Pengumuman',
      'subtitle': 'Pengumuman',
      'icon': Icons.upload_file_outlined,
      'color': Colors.orange,
      'page': Scaffold(
        appBar: AppBar(title: const Text('Materi Ajar')),
        body: const Center(child: Text('Halaman Materi Ajar')),
      ),
    },
    {
      'title': 'Jadwal Mengajar',
      'subtitle': 'Lihat jadwal kelas Anda',
      'icon': Icons.calendar_month_outlined,
      'color': Colors.purple,
      'page': ViewSchedulePage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Cek status Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Background dinamis: Default gelap (null) jika Dark Mode, Grey[100] jika Light Mode
      backgroundColor: isDark ? null : Colors.grey[100], 
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, // Membuat kartu berbentuk persegi
              ),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                // 3. Terapkan animasi pada setiap kartu
                return _AnimatedGridItem(
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
    final userName = auth.currentUser?.name ?? 'Guru';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.blue.shade600],
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
                  'Selamat Mengajar,',
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
    // Cek Dark mode untuk warna teks subtitle
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      // Shadow color dibuat lebih halus
      shadowColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.2),
      // Warna Card otomatis mengikuti Theme (Putih di Light, Abu Gelap di Dark)
      color: Theme.of(context).cardColor, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      // Warna Text otomatis ikut tema (Hitam/Putih)
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                // Warna subtitle disesuaikan agar terlihat di background gelap
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget terpisah untuk menangani animasi setiap item grid
class _AnimatedGridItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedGridItem({required this.index, required this.child});

  @override
  State<_AnimatedGridItem> createState() => _AnimatedGridItemState();
}

class _AnimatedGridItemState extends State<_AnimatedGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Animasi diberi sedikit delay berdasarkan posisinya
    final delay = Duration(milliseconds: widget.index * 100);
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}