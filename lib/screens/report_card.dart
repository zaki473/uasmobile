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
  // --- STYLE CONSTANTS ---
  final Color rgPrimary = const Color(0xFF3ecfde);
  final Color bgGrey = const Color(0xFFF4F7F9);
  final Color textDark = const Color(0xFF2D3E50);
  final Color textGrey = const Color(0xFF9B9B9B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<GradeProvider>(context, listen: false)
            .fetchGrades(auth.currentUser!.uid);
      }
    });
  }

  Color _getGradeColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  // ----------------------------------------------------------
  // FUNGSI GENERATE PDF (LOGIC TIDAK DIUBAH)
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

    return Scaffold(
      backgroundColor: bgGrey, // Background Abu Muda
      
      // --- APP BAR CLEAN ---
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Laporan Hasil Belajar',
          style: TextStyle(
            color: textDark, 
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),

      body: Consumer<GradeProvider>(
        builder: (context, gradeProv, child) {
          if (gradeProv.isLoading) {
            return Center(child: CircularProgressIndicator(color: rgPrimary));
          }

          if (gradeProv.grades.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text('Data nilai belum tersedia.', style: TextStyle(color: textGrey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // --- LIST NILAI ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: gradeProv.grades.length,
                  itemBuilder: (context, index) {
                    final grade = gradeProv.grades[index];
                    return _AnimatedListItem(
                      index: index,
                      child: _buildGradeCard(grade),
                    );
                  },
                ),
              ),

              // --- SUMMARY CARD (Sticky Bottom) ---
              _buildSummaryCard(gradeProv, studentName),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET KARTU NILAI (MODERN STYLE) ---
  Widget _buildGradeCard(Grade grade) {
    final gradeColor = _getGradeColor(grade.finalScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Detail Mata Pelajaran
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade.subject,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                // Chip detail nilai kecil
                Wrap(
                  spacing: 8,
                  children: [
                    _miniScore("Tugas", grade.tugas),
                    _miniScore("UTS", grade.uts),
                    _miniScore("UAS", grade.uas),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 2. Nilai Akhir (Lingkaran)
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gradeColor, width: 3),
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    grade.finalScore.toStringAsFixed(0),
                    style: TextStyle(
                      color: gradeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
    );
  }

  // Helper kecil untuk menampilkan skor tugas/uts/uas
  Widget _miniScore(String label, double score) {
    return Text(
      "$label: ${score.toInt()}",
      style: TextStyle(fontSize: 11, color: textGrey),
    );
  }
  
  // --- WIDGET RINGKASAN (BOTTOM BAR) ---
  Widget _buildSummaryCard(GradeProvider gradeProv, String studentName) {
    final average = gradeProv.getAverage();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5), // Shadow ke atas
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Info Rata-rata
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rata-rata Nilai',
                  style: TextStyle(color: textGrey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  average.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: rgPrimary, // Cyan Number
                  ),
                ),
              ],
            ),
            
            // Tombol PDF
            ElevatedButton.icon(
              onPressed: () => _generatePdf(gradeProv.grades, average, studentName),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Merah agar beda (Action Button)
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.print_rounded, size: 20),
              label: const Text("Cetak PDF", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ANIMASI ITEM (TIDAK DIUBAH) ---
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