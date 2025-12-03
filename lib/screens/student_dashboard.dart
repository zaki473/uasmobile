import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:fl_chart/fl_chart.dart';
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
  // Palette Warna Ruangguru Style
  final Color rgPrimary = const Color(0xFF3ecfde);
  final Color rgDark = const Color(0xFF00A8E8);
  
  final Color lightBgColor = const Color(0xFFFAFAFA);
  final Color lightTextDark = const Color(0xFF2D3E50);

  // Variable untuk menyimpan Data Grafik dari Firestore
  double avgTugas = 0.0;
  double avgUts = 0.0;
  double avgUas = 0.0;
  bool isLoadingGraph = true; // Loading state untuk grafik

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
  ];

  @override
  void initState() {
    super.initState();
    // Panggil fungsi ambil data saat aplikasi dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGraphData();
    });
  }

  // --- FUNGSI AMBIL DATA DARI FIRESTORE ---
  Future<void> _fetchGraphData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Pastikan user id tersedia. Sesuaikan 'uid' dengan field ID di model user kamu
    final String? studentId = auth.currentUser?.uid; 

    if (studentId == null) {
      setState(() => isLoadingGraph = false);
      return;
    }

    try {
      // GANTI 'grades' SESUAI NAMA COLLECTION DI FIRESTORE KAMU
      // Misal: 'nilai', 'report_cards', atau 'grades'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('grades') 
          .where('studentId', isEqualTo: studentId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        double totalTugas = 0;
        double totalUts = 0;
        double totalUas = 0;
        int count = snapshot.docs.length;

        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Pakai (?? 0) untuk jaga-jaga kalau datanya null
          totalTugas += (data['tugas'] ?? 0).toDouble();
          totalUts += (data['uts'] ?? 0).toDouble();
          totalUas += (data['uas'] ?? 0).toDouble();
        }

        // Hitung Rata-rata
        if (mounted) {
          setState(() {
            avgTugas = totalTugas / count;
            avgUts = totalUts / count;
            avgUas = totalUas / count;
            isLoadingGraph = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoadingGraph = false);
      }
    } catch (e) {
      debugPrint("Error fetching graph data: $e");
      if (mounted) setState(() => isLoadingGraph = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.currentUser?.name ?? 'Siswa';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color currentBgColor = isDark ? const Color(0xFF121212) : lightBgColor;
    final Color currentTextColor = isDark ? Colors.white : lightTextDark;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white; 

    return Scaffold(
      backgroundColor: currentBgColor, 
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            _buildFancyHeader(context, userName, auth, isDark),

            const SizedBox(height: 20),

            // INFO BANNER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInfoBanner(isDark, cardColor, currentTextColor),
            ),
            
            const SizedBox(height: 20),

            // --- BAGIAN GRAFIK ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Statistik Rata-rata Nilai",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: currentTextColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildChartSection(isDark, cardColor, currentTextColor),
            ),
            // --------------------

            const SizedBox(height: 25),

            // TITLE MENU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Menu Utama",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: currentTextColor, 
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

  // --- WIDGET CHART (DISESUAIKAN DENGAN FIRESTORE) ---
  Widget _buildChartSection(bool isDark, Color cardColor, Color textColor) {
    List<Color> gradientColors = [rgPrimary, rgDark];

    if (isLoadingGraph) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 220, // Agak ditinggikan sedikit
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1, // Agar setiap titik punya label
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  String text;
                  // Mapping Sumbu X ke Nama Field Database
                  switch (value.toInt()) {
                    case 0: text = 'Tugas'; break;
                    case 2: text = 'UTS'; break;
                    case 4: text = 'UAS'; break;
                    default: return Container();
                  }
                  return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20, // Interval angka di kiri
                getTitlesWidget: (value, meta) {
                   const style = TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  );
                  return Text(value.toInt().toString(), style: style);
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 4, // Maksimum X dikurangi karena cuma ada 3 data
          minY: 0,
          maxY: 100, // Nilai maksimal 100
          lineBarsData: [
            LineChartBarData(
              // MENGGUNAKAN DATA ASLI DARI VARIABEL STATE
              spots: [
                FlSpot(0, avgTugas), // Posisi 0 = Tugas
                FlSpot(2, avgUts),   // Posisi 2 = UTS
                FlSpot(4, avgUas),   // Posisi 4 = UAS
              ],
              isCurved: true,
              gradient: LinearGradient(colors: gradientColors),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors.map((color) => color.withOpacity(0.2)).toList(),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
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
        color: cardColor, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_rounded, color: isDark ? Colors.blue[300] : Colors.blue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Jangan lupa untuk selalu memeriksa pengumuman terbaru dari sekolah!",
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPACT CARD DESIGN ---
  Widget _buildCompactGridCard(BuildContext context, Map<String, dynamic> item, bool isDark, Color cardColor, Color titleColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03), 
            spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 4),
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
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                    )
                  ],
                ),
                const Spacer(), 
                Text(
                  item['title'],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor, height: 1.2),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'],
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[500] : Colors.grey[500]),
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

// --- ANIMASI ---
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