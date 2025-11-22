import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grade_provider.dart';

class InputGrade extends StatefulWidget {
  const InputGrade({super.key});

  @override
  State<InputGrade> createState() => _InputGradeState();
}

class _InputGradeState extends State<InputGrade> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final subjectC = TextEditingController();
  final tugasC = TextEditingController();
  final utsC = TextEditingController();
  final uasC = TextEditingController();

  // Variable ID Siswa
  String? selectedStudentId; 

  @override
  void dispose() {
    subjectC.dispose();
    tugasC.dispose();
    utsC.dispose();
    uasC.dispose();
    super.dispose();
  }

  // --- WIDGET STYLING ---
  Widget _buildInputContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.indigoAccent),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.indigoAccent, width: 1.5),
      ),
    );
  }

  // --- BUILDER: DROPDOWN SISWA (UPDATED) ---
  Widget _buildStudentDropdown() {
    return StreamBuilder<QuerySnapshot>(
      // 🔹 PERUBAHAN DISINI:
      // Ambil dari 'users', Filter role == 'siswa', Urutkan nama
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'siswa') 
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Handle Loading
        if (!snapshot.hasData) {
          return _buildInputContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 15),
                  Text("Memuat data siswa...", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        }

        // 2. Handle Error / Kosong
        if (snapshot.hasError) {
           return _buildInputContainer(child: ListTile(title: Text("Error: ${snapshot.error}")));
        }
        
        if (snapshot.data!.docs.isEmpty) {
           return _buildInputContainer(
             child: const ListTile(
               leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
               title: Text("Belum ada user 'siswa'"),
             )
           );
        }

        // 3. Buat List Dropdown Item
        List<DropdownMenuItem<String>> studentItems = [];
        for (var doc in snapshot.data!.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          String name = data['name'] ?? 'Tanpa Nama';
          String uid = doc.id; // 🔹 PENTING: Pakai UID Dokumen agar nyambung ke Auth

          studentItems.add(
            DropdownMenuItem(
              value: uid, 
              child: Text(
                name, 
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        // 4. Render Dropdown
        return _buildInputContainer(
          child: DropdownButtonFormField<String>(
            decoration: _inputDecoration("Pilih Siswa", Icons.person_search_outlined),
            value: selectedStudentId,
            isExpanded: true,
            hint: const Text("Klik untuk memilih siswa"),
            icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.indigo),
            items: studentItems,
            onChanged: (value) {
              setState(() {
                selectedStudentId = value;
              });
            },
            validator: (value) => value == null ? "Harus memilih siswa" : null,
          ),
        );
      },
    );
  }

  // --- BUILDER: TEXT FIELD BIASA ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return _buildInputContainer(
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return '$label tidak boleh kosong';
          if (isNumber && double.tryParse(value) == null) return 'Harus angka';
          return null;
        },
        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradeProv = Provider.of<GradeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Input Nilai Siswa', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 15),
                child: Text("Identitas Siswa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ),
              
              _buildStudentDropdown(), // DROPDOWN

              _buildTextField(controller: subjectC, label: 'Mata Pelajaran', icon: Icons.menu_book_rounded),

              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 15),
                child: Text("Input Penilaian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ),

              _buildTextField(controller: tugasC, label: 'Nilai Tugas', icon: Icons.assignment_outlined, isNumber: true),
              
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: utsC, label: 'Nilai UTS', icon: Icons.fact_check_outlined, isNumber: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField(controller: uasC, label: 'Nilai UAS', icon: Icons.history_edu_outlined, isNumber: true)),
                ],
              ),
              
              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.indigoAccent.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await gradeProv.addGrade(
                          studentId: selectedStudentId!, 
                          subject: subjectC.text,
                          tugas: double.parse(tugasC.text),
                          uts: double.parse(utsC.text),
                          uas: double.parse(uasC.text),
                        );
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Nilai berhasil disimpan!'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green.shade600),
                          );
                          setState(() { selectedStudentId = null; });
                          subjectC.clear(); tugasC.clear(); utsC.clear(); uasC.clear();
                        }
                      } catch (e) {
                        if(context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    }
                  },
                  child: const Text('Simpan Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}