import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import Provider & Model Anda
import '../providers/auth_provider.dart';
import '../providers/grade_provider.dart';
import '../models/grade.dart';

// Import Package PDF & Printing
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportCard extends StatefulWidget {
  const ReportCard({super.key});

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<GradeProvider>(context, listen: false)
            .fetchGrades(auth.currentUser!.id);
      }
    });
  }

  Color _getGradeColor(double score) {
    if (score >= 85) return Colors.green.shade600;
    if (score >= 70) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  // ----------------------------------------------------------
  // FUNGSI GENERATE PDF (TETAP STANDAR PUTIH UNTUK PRINTING)
  // ----------------------------------------------------------
  Future<void> _generatePdf(List<Grade> grades, double average, String studentName) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Laporan Hasil Belajar', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Nama Siswa: $studentName'),
              pw.Text('Tanggal Cetak: ${DateTime.now().toString().split(' ')[0]}'),
              pw.SizedBox(height: 20),
              
              // Tabel Nilai
              pw.Table.fromTextArray(
                context: context,
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headerHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                },
                headers: ['Mata Pelajaran', 'Tugas', 'UTS', 'UAS', 'Akhir', 'Predikat'],
                data: grades.map((g) => [
                  g.subject,
                  g.tugas.toString(),
                  g.uts.toString(),
                  g.uas.toString(),
                  g.finalScore.toStringAsFixed(1),
                  g.predicate
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              
              // Total Rata-rata
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Rata-rata Nilai: ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text(average.toStringAsFixed(2), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                ]
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final studentName = auth.currentUser?.name ?? "Siswa";

    // 1. Deteksi Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 2. Warna UI
    final scaffoldBg = isDark ? null : Colors.grey[100];
    final loadingTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBg,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Memuat data rapor...', style: TextStyle(color: loadingTextColor)),
                ],
              ),
            );
          }

          if (gradeProv.grades.isEmpty) {
            return Center(
              child: Text(
                'Data nilai belum tersedia.', 
                style: TextStyle(color: loadingTextColor)
              )
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: gradeProv.grades.length,
                  itemBuilder: (context, index) {
                    final grade = gradeProv.grades[index];
                    return _AnimatedListItem(
                      index: index,
                      child: _buildGradeCard(grade), // Pass grade only
                    );
                  },
                ),
              ),
              _buildSummaryCard(gradeProv, studentName),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGradeCard(Grade grade) {
    final gradeColor = _getGradeColor(grade.finalScore);
    
    // Variabel tema untuk Card
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Theme.of(context).cardColor : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey[600];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      // Shadow transparan di dark mode
      shadowColor: isDark ? Colors.transparent : Colors.black26,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // Tambah border tipis di dark mode
        side: isDark ? const BorderSide(color: Colors.white10) : BorderSide.none
      ),
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
                          color: titleColor, // <-- Dinamis
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tugas: ${grade.tugas} • UTS: ${grade.uts} • UAS: ${grade.uas}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtitleColor, // <-- Dinamis
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
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
  
  // ----------------------------------------------------------
  // WIDGET SUMMARY
  // ----------------------------------------------------------
  Widget _buildSummaryCard(GradeProvider gradeProv, String studentName) {
    final average = gradeProv.getAverage();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Theme.of(context).cardColor : Colors.white;
    final labelColor = isDark ? Colors.white70 : Colors.grey[600];
    final valueColor = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        // Border tipis di dark mode
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bagian Kiri: Nilai Rata-rata
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rata-rata Nilai',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: labelColor),
                ),
                const SizedBox(height: 4),
                Text(
                  average.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                ),
              ],
            ),
            
            // Bagian Kanan: Tombol Export PDF
            ElevatedButton.icon(
              onPressed: () => _generatePdf(gradeProv.grades, average, studentName),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text("Export PDF"),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Animasi List (Tetap)
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