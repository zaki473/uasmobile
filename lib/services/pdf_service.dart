import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/grade.dart';
import '../models/student.dart';

class PdfService {
  /// Generate file PDF rapor siswa
  Future<void> generateReport(Student student, List<Grade> grades) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RAPOR SISWA',
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Nama: ${student.name}'),
                pw.Text('NIS: ${student.nis}'),
                pw.Text('Kelas: ${student.kelas}'),
                pw.Text('Jurusan: ${student.jurusan}'),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: ['Mata Pelajaran', 'Tugas', 'UTS', 'UAS', 'Akhir', 'Predikat'],
                  data: grades.map((g) {
                    return [
                      g.subject,
                      g.tugas.toString(),
                      g.uts.toString(),
                      g.uas.toString(),
                      g.finalScore.toStringAsFixed(1),
                      g.predicate
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.blue),
                  cellAlignment: pw.Alignment.center,
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Tertanda,\nWali Kelas',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
