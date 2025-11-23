import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentViewSchedulePage extends StatefulWidget {
  @override
  State<StudentViewSchedulePage> createState() =>
      _StudentViewSchedulePageState();
}

class _StudentViewSchedulePageState extends State<StudentViewSchedulePage> {
  // Warna khas Ruangguru (Cyan/Light Blue palette)
  final Color rgPrimary = const Color(0xFF3ecfde);
  final Color rgAccent = const Color(0xFF28b5c5);
  final Color bgGrey = const Color(0xFFF4F7F9);
  final Color textDark = const Color(0xFF4A4A4A);
  final Color textGrey = const Color(0xFF9B9B9B);

  // Helper untuk menentukan urutan hari
  int getDayOrder(String? hari) {
    switch (hari?.toLowerCase()) {
      case 'senin': return 1;
      case 'selasa': return 2;
      case 'rabu': return 3;
      case 'kamis': return 4;
      case 'jumat': return 5;
      case 'sabtu': return 6;
      case 'minggu': return 7;
      default: return 8; // Untuk data yg harinya typo atau kosong ditaruh paling bawah
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        title: Text(
          "Jadwal Pelajaran",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Icon(Icons.sort_rounded, color: rgPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Jadwal Pelajaran Hari Ini",
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jadwal_pelajaran')
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
                        Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text(
                          "Belum ada jadwal pelajaran",
                          style: TextStyle(color: textGrey),
                        ),
                      ],
                    ),
                  );
                }

                // --- LOGIKA SORTING (PENGURUTAN) ---
                // 1. Ambil semua docs
                List<QueryDocumentSnapshot> docs = snapshot.data!.docs.toList();

                // 2. Lakukan sorting manual
                docs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;

                  // Sort level 1: Berdasarkan HARI
                  int orderA = getDayOrder(dataA['hari']);
                  int orderB = getDayOrder(dataB['hari']);
                  
                  if (orderA != orderB) {
                    return orderA.compareTo(orderB);
                  } else {
                    // Sort level 2: Jika harinya sama, urutkan berdasarkan JAM MULAI
                    String jamA = dataA['jam_mulai'] ?? "";
                    String jamB = dataB['jam_mulai'] ?? "";
                    return jamA.compareTo(jamB);
                  }
                });
                // --- END LOGIKA SORTING ---

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;

                    String mapel = data['mapel'] ?? "Tanpa Mapel";
                    String guru = data['guru'] ?? "-";
                    String hari = data['hari'] ?? "-";
                    String jamMulai = data['jam_mulai'] ?? "--:--";
                    String jamSelesai = data['jam_selesai'] ?? "--:--";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            // Kolom Kiri: Jam
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
                                      color: textGrey,
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
                            
                            // Kolom Kanan: Detail
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
                                        hari, // Pastikan data di DB tulisannya misal "Senin"
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
                                        color: textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    
                                    // Nama Guru
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline,
                                            size: 16, color: textGrey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            guru,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textGrey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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