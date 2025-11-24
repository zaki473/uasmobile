import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSchedulePage extends StatefulWidget {
  @override
  _ManageSchedulePageState createState() => _ManageSchedulePageState();
}

class _ManageSchedulePageState extends State<ManageSchedulePage> {
  final CollectionReference scheduleCollection = FirebaseFirestore.instance
      .collection('jadwal_pelajaran');

  // --- STYLE CONSTANTS (Branding tetap, warna UI dinamis) ---
  final Color rgPrimary = const Color(0xFF3ecfde);
  final Color rgAccent = const Color(0xFF28b5c5);
  
  // Controllers
  final TextEditingController mapelC = TextEditingController();
  final TextEditingController hariC = TextEditingController();
  final TextEditingController mulaiC = TextEditingController();
  final TextEditingController selesaiC = TextEditingController();

  // Dropdown
  String? selectedGuruId;
  String? selectedGuruName;

  List<Map<String, dynamic>> guruList = [];

  // Helper Sorting Hari
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

  // Ambil data guru
  Future<void> loadGuru() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'guru')
        .get();

    if (mounted) {
      setState(() {
        guruList = snapshot.docs
            .map((d) => {'id': d.id, 'nama': d['nama']})
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadGuru();
  }

  void clearFields() {
    mapelC.clear();
    hariC.clear();
    mulaiC.clear();
    selesaiC.clear();
    selectedGuruId = null;
    selectedGuruName = null;
  }

  // Field Widget Styled & Dark Mode Aware
  Widget field(BuildContext context, String label, TextEditingController c) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50];
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white70 : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        style: TextStyle(color: textColor), // Warna teks input
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor),
          filled: true,
          fillColor: fillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: rgPrimary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ----------------------------
  //   ADD DIALOG
  // ----------------------------
  void showAddDialog() {
    clearFields();

    showDialog(
      context: context,
      builder: (context) {
        // Cek tema di dalam dialog builder
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF4A4A4A);
        final inputFill = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50];

        return AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Tambah Jadwal", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field(context, "Mata Pelajaran", mapelC),
                
                // Styling Dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    dropdownColor: bgColor,
                    value: selectedGuruId,
                    items: guruList.map((guru) {
                      return DropdownMenuItem<String>(
                        value: guru['id'],
                        child: Text(guru['nama'], style: TextStyle(color: textColor)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGuruId = value;
                        selectedGuruName = guruList.firstWhere(
                          (e) => e['id'] == value,
                        )['nama'];
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Guru Pengajar",
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                      filled: true,
                      fillColor: inputFill,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: rgPrimary, width: 2),
                      ),
                    ),
                  ),
                ),

                field(context, "Hari (ex: Senin)", hariC),
                Row(
                  children: [
                    Expanded(child: field(context, "Mulai (07:00)", mulaiC)),
                    const SizedBox(width: 10),
                    Expanded(child: field(context, "Selesai (08:40)", selesaiC)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal", style: TextStyle(color: isDark ? Colors.white70 : Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: rgPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (selectedGuruId == null) return;

                await scheduleCollection.add({
                  "mapel": mapelC.text,
                  "guru": selectedGuruName,
                  "guruId": selectedGuruId,
                  "hari": hariC.text,
                  "jam_mulai": mulaiC.text,
                  "jam_selesai": selesaiC.text,
                });

                if(context.mounted) Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------
  //   EDIT DIALOG
  // ----------------------------
  void showEditDialog(String id, Map<String, dynamic> data) {
    mapelC.text = data['mapel'];
    hariC.text = data['hari'];
    mulaiC.text = data['jam_mulai'];
    selesaiC.text = data['jam_selesai'];

    selectedGuruId = data['guruId'];
    selectedGuruName = data['guru'];

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF4A4A4A);
        final inputFill = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50];

        return AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Edit Jadwal", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field(context, "Mata Pelajaran", mapelC),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    dropdownColor: bgColor,
                    value: selectedGuruId,
                    items: guruList.map((guru) {
                      return DropdownMenuItem<String>(
                        value: guru['id'],
                        child: Text(guru['nama'], style: TextStyle(color: textColor)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGuruId = value;
                        selectedGuruName = guruList.firstWhere(
                          (e) => e['id'] == value,
                        )['nama'];
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Guru Pengajar",
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                      filled: true,
                      fillColor: inputFill,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: rgPrimary, width: 2),
                      ),
                    ),
                  ),
                ),

                field(context, "Hari (ex: Senin)", hariC),
                Row(
                  children: [
                    Expanded(child: field(context, "Mulai", mulaiC)),
                    const SizedBox(width: 10),
                    Expanded(child: field(context, "Selesai", selesaiC)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal", style: TextStyle(color: isDark ? Colors.white70 : Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: rgPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text("Update", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await scheduleCollection.doc(id).update({
                  "mapel": mapelC.text,
                  "guru": selectedGuruName,
                  "guruId": selectedGuruId,
                  "hari": hariC.text,
                  "jam_mulai": mulaiC.text,
                  "jam_selesai": selesaiC.text,
                });
                if(context.mounted) Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteJadwal(String id) async {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hapus Jadwal?"),
        content: const Text("Data tidak dapat dikembalikan."),
        actions: [
          TextButton(child: const Text("Batal"), onPressed: () => Navigator.pop(c)),
          TextButton(
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            onPressed: () async {
               Navigator.pop(c);
               await scheduleCollection.doc(id).delete();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 2. Tentukan Warna UI Utama
    final scaffoldBg = isDark ? null : const Color(0xFFF4F7F9);
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF4A4A4A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF9B9B9B);
    final iconColor = isDark ? Colors.white70 : const Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // Transparan agar ikut tema scaffold
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
        title: Text(
          "Kelola Jadwal",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: rgPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: showAddDialog,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: scheduleCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
             return Center(child: CircularProgressIndicator(color: rgPrimary));
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Belum ada data jadwal.", style: TextStyle(color: subtitleColor)));
          }

          // --- LOGIKA SORTING (HARI & JAM) ---
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
          // -----------------------------------

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor, // <-- Warna kartu dinamis
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  // Tambah border tipis di dark mode biar kartu terlihat jelas
                  border: isDark ? Border.all(color: Colors.white10) : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Kolom Waktu
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: rgPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              data['jam_mulai'] ?? "--:--",
                              style: TextStyle(fontWeight: FontWeight.bold, color: rgAccent),
                            ),
                            Text("-", style: TextStyle(fontSize: 10, color: subtitleColor)),
                            Text(
                              data['jam_selesai'] ?? "--:--",
                              style: TextStyle(fontWeight: FontWeight.w600, color: rgAccent, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 16),

                      // Kolom Detail
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                data['hari'] ?? "-",
                                style: TextStyle(color: Colors.orange[800], fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['mapel'] ?? "-",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                            ),
                            Text(
                              data['guru'] ?? "-",
                              style: TextStyle(color: subtitleColor, fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                      // Kolom Aksi (Edit/Delete)
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                              constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                showEditDialog(docs[i].id, data);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                              constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                deleteJadwal(docs[i].id);
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}