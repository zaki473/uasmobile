import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/grade_provider.dart';
import '../models/grade.dart'; // Pastikan Anda mengimpor model Grade

class ReportCard extends StatefulWidget {
  const ReportCard({super.key});

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  @override
  void initState() {
    super.initState();
    // Menggunakan addPostFrameCallback untuk memastikan context sudah siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // Asumsi: currentUser tidak akan null di halaman ini
      Provider.of<GradeProvider>(context, listen: false)
          .fetchGrades(auth.currentUser!.linkedId!);
    });
  }

  // Fungsi untuk menentukan warna berdasarkan nilai
  Color _getGradeColor(double score) {
    if (score >= 85) return Colors.green.shade600;
    if (score >= 70) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // AppBar yang lebih modern dengan gradien
      appBar: AppBar(
        title: const Text('Rapor Belajar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<GradeProvider>(
        builder: (context, gradeProv, child) {
          if (gradeProv.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data rapor...'),
                ],
              ),
            );
          }

          if (gradeProv.grades.isEmpty) {
            return const Center(child: Text('Data nilai belum tersedia.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: gradeProv.grades.length,
                  itemBuilder: (context, index) {
                    final grade = gradeProv.grades[index];
                    // Terapkan animasi pada setiap kartu
                    return _AnimatedListItem(
                      index: index,
                      child: _buildGradeCard(grade),
                    );
                  },
                ),
              ),
              _buildSummaryCard(gradeProv, auth.currentUser!.linkedId!),
            ],
          );
        },
      ),
    );
  }

  // Widget untuk kartu setiap mata pelajaran
  Widget _buildGradeCard(Grade grade) {
    final gradeColor = _getGradeColor(grade.finalScore);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grade.subject,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tugas: ${grade.tugas} • UTS: ${grade.uts} • UAS: ${grade.uas}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Lingkaran untuk nilai akhir
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gradeColor, width: 2.5),
                  ),
                  child: Text(
                    grade.finalScore.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: gradeColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  grade.predicate,
                  style: TextStyle(
                    color: gradeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
  
  // Widget untuk kartu ringkasan di bagian bawah
  Widget _buildSummaryCard(GradeProvider gradeProv, String studentId) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rata-rata Nilai',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              gradeProv.getAverage(studentId).toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget animasi yang bisa digunakan kembali
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

    final delay = Duration(milliseconds: widget.index * 100);
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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