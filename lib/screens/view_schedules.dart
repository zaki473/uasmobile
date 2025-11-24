import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewSchedulePage extends StatelessWidget {
  final String uidGuru = FirebaseAuth.instance.currentUser!.uid;

  // --- 1. CONSTANTS (Tetap disimpan untuk branding) ---
  final Color rgPrimary = const Color(0xFF3ecfde);
  final Color rgAccent = const Color(0xFF28b5c5);

  // --- 2. HELPER SORTING HARI ---
  int getDayOrder(String? hari) {
    switch (hari?.toLowerCase()) {
      case 'senin': return 1;
      case 'selasa': return 2;
      case 'rabu': return 3;
      case 'kamis': return 4;
      case 'jumat': return 5;
      case 'sabtu': return 6;
      case 'minggu': return 7;
      default: return 8;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Tentukan Warna UI Dinamis
    final scaffoldBg = isDark ? null : const Color(0xFFF4F7F9);
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF4A4A4A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF9B9B9B);
    final bannerColor = isDark ? Theme.of(context).cardColor : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg, 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // Transparan agar ikut scaffold
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor), // Icon back dinamis
        title: Text(
          "Jadwal Mengajar",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Banner Kecil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: bannerColor, // <-- Warna banner dinamis
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200
                )
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.school_rounded, color: rgPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Daftar Kelas Mengajar Anda",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // --- STREAM ASLI (TIDAK DIUBAH) ---
              stream: FirebaseFirestore.instance
                  .collection('jadwal_pelajaran')
                  .where('guruId', isEqualTo: uidGuru)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: rgPrimary),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.free_breakfast_outlined, size: 60, color: subTextColor),
                        const SizedBox(height: 10),
                        Text(
                          "Anda belum memiliki jadwal mengajar",
                          style: TextStyle(color: subTextColor),
                        ),
                      ],
                    ),
                  );
                }

                // --- LOGIKA SORTING ---
                List<QueryDocumentSnapshot> docs = snapshot.data!.docs.toList();

                docs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;

                  int orderA = getDayOrder(dataA['hari']);
                  int orderB = getDayOrder(dataB['hari']);
                  
                  if (orderA != orderB) {
                    return orderA.compareTo(orderB);
                  } else {
                    String jamA = dataA['jam_mulai'] ?? "";
                    String jamB = dataB['jam_mulai'] ?? "";
                    return jamA.compareTo(jamB);
                  }
                });
                // ---------------------

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;

                    String mapel = data['mapel'] ?? "Tanpa Mapel";
                    String hari = data['hari'] ?? "-";
                    String jamMulai = data['jam_mulai'] ?? "--:--";
                    String jamSelesai = data['jam_selesai'] ?? "--:--";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: cardColor, // <-- Warna kartu dinamis
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            // Shadow dikurangi saat dark mode
                            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        // Tambahan border tipis di dark mode
                        border: isDark ? Border.all(color: Colors.white10) : null,
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            // Bagian Kiri: Jam (Warna Biru)
                            Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: rgPrimary.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    jamMulai,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: rgAccent,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "s/d",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: subTextColor,
                                    ),
                                  ),
                                  Text(
                                    jamSelesai,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: rgAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Bagian Kanan: Detail
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Chip Hari
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orangeAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        hari,
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Nama Mapel
                                    Text(
                                      mapel,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor, // <-- Teks judul dinamis
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),

                                    // Info tambahan
                                    Row(
                                      children: [
                                        Icon(Icons.class_outlined,
                                            size: 16, color: subTextColor),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            "Pengajar: Anda",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: subTextColor, // <-- Teks sub dinamis
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}