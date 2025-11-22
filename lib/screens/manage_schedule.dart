import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSchedulePage extends StatefulWidget {
  @override
  _ManageSchedulePageState createState() => _ManageSchedulePageState();
}

class _ManageSchedulePageState extends State<ManageSchedulePage> {
  final CollectionReference scheduleCollection = FirebaseFirestore.instance
      .collection('jadwal_pelajaran');

  // Controllers
  final TextEditingController mapelC = TextEditingController();
  final TextEditingController hariC = TextEditingController();
  final TextEditingController mulaiC = TextEditingController();
  final TextEditingController selesaiC = TextEditingController();

  // Dropdown
  String? selectedGuruId;
  String? selectedGuruName;

  List<Map<String, dynamic>> guruList = [];

  // Ambil data guru
  Future<void> loadGuru() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'guru')
        .get();

    guruList = snapshot.docs
        .map((d) => {'id': d.id, 'nama': d['nama']})
        .toList();

    setState(() {});
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

  // ----------------------------
  //   ADD DIALOG
  // ----------------------------
  void showAddDialog() {
    clearFields();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Jadwal"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                field("Mata Pelajaran", mapelC),

                SizedBox(height: 12),

                // 🔵 FIXED DROPDOWN
                DropdownButtonFormField<String>(
                  value: selectedGuruId,
                  items: guruList.map((guru) {
                    return DropdownMenuItem<String>(
                      value: guru['id'],
                      child: Text(guru['nama']),
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
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 12),
                field("Hari", hariC),
                field("Jam Mulai", mulaiC),
                field("Jam Selesai", selesaiC),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Simpan"),
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

                Navigator.pop(context);
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
        return AlertDialog(
          title: Text("Edit Jadwal"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                field("Mata Pelajaran", mapelC),

                SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedGuruId,
                  items: guruList.map((guru) {
                    return DropdownMenuItem<String>(
                      value: guru['id'],
                      child: Text(guru['nama']),
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
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 12),
                field("Hari", hariC),
                field("Jam Mulai", mulaiC),
                field("Jam Selesai", selesaiC),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Update"),
              onPressed: () async {
                await scheduleCollection.doc(id).update({
                  "mapel": mapelC.text,
                  "guru": selectedGuruName,
                  "guruId": selectedGuruId, // sesuai Firestore
                  "guru_id": selectedGuruId, // ikut diset juga biar tidak null
                  "hari": hariC.text,
                  "jam_mulai": mulaiC.text,
                  "jam_selesai": selesaiC.text,
                });
              },
            ),
          ],
        );
      },
    );
  }

  // Field Widget
  Widget field(String label, TextEditingController c) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void deleteJadwal(String id) async {
    await scheduleCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kelola Jadwal Pelajaran")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: showAddDialog,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: scheduleCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(12),
                child: ListTile(
                  title: Text(data['mapel']),
                  subtitle: Text(
                    "${data['guru']} • ${data['hari']} • ${data['jam_mulai']} - ${data['jam_selesai']}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showEditDialog(docs[i].id, data);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteJadwal(docs[i].id);
                        },
                      ),
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
