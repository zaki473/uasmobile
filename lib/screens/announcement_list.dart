import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pengumuman.dart';
import 'announcement_edit.dart';

class AnnouncementList extends StatelessWidget {
  final bool showDelete;
  const AnnouncementList({Key? key, required this.showDelete}) : super(key: key);

  // --- STYLE CONSTANTS ---
  final Color rgPrimary = const Color(0xFF3ecfde);
  final Color bgCard = Colors.white;
  final Color bgContentBox = const Color(0xFFF8F9FA); // Warna box isi abu sangat muda
  final Color textDark = const Color(0xFF2D3E50);
  final Color textGrey = const Color(0xFF637381);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("pengumuman")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: rgPrimary));
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text("Belum ada pengumuman", style: TextStyle(color: textGrey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN HEADER (Icon + Judul + Tombol) ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon Speaker Kecil
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.campaign_rounded, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        
                        // Judul
                        Expanded(
                          child: Text(
                            data['title'] ?? "Tanpa Judul",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Tombol Edit/Delete (Jika Admin)
                        if (showDelete) 
                          Row(
                            children: [
                              _actionButton(
                                icon: Icons.edit_rounded,
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditPengumumanScreen(
                                        id: data.id,
                                        oldTitle: data['title'],
                                        oldContent: data['content'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _actionButton(
                                icon: Icons.delete_rounded,
                                color: Colors.red,
                                onTap: () {
                                  FirebaseFirestore.instance
                                      .collection("pengumuman")
                                      .doc(data.id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // --- BAGIAN BOX ISI PENGUMUMAN ---
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgContentBox, // Background abu sangat muda
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200), // Garis tepi halus
                    ),
                    child: Text(
                      data['content'] ?? "-",
                      style: TextStyle(
                        fontSize: 14,
                        color: textGrey,
                        height: 1.5, // Spasi antar baris biar enak dibaca
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper Widget untuk tombol kecil
  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}