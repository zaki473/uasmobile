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

  // --- STYLE CONSTANTS (Ruangguru Palette) ---
  final Color rgPrimary = const Color(0xFF3ecfde); // Cyan Utama
  final Color rgDark = const Color(0xFF00A8E8);    // Biru Aksen
  final Color bgGrey = const Color(0xFFF4F7F9);
  final Color textDark = const Color(0xFF2D3E50);
  final Color textGrey = const Color(0xFF9B9B9B);

  @override
  void dispose() {
    subjectC.dispose();
    tugasC.dispose();
    utsC.dispose();
    uasC.dispose();
    super.dispose();
  }

  // --- WIDGET STYLING ---
  Widget _buildInputContainer(BuildContext context, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textGrey, fontSize: 14),
      prefixIcon: Icon(icon, color: rgPrimary),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: rgPrimary, width: 1.5),
      ),
    );
  }

  // --- BUILDER: DROPDOWN SISWA ---
  Widget _buildStudentDropdown(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'siswa') 
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Loading
        if (!snapshot.hasData) {
          return _buildInputContainer(
            context,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: rgPrimary)),
                  const SizedBox(width: 15),
                  Text("Memuat data siswa...", style: TextStyle(color: textGrey)),
                ],
              ),
            ),
          );
        }

        // 2. Error / Kosong
        if (snapshot.hasError) {
           return _buildInputContainer(context, child: ListTile(title: Text("Error database", style: TextStyle(color: textDark))));
        }
        
        if (snapshot.data!.docs.isEmpty) {
           return _buildInputContainer(
             context,
             child: const ListTile(
               leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
               title: Text("Belum ada user 'siswa'"),
             )
           );
        }

        // 3. List Dropdown
        List<DropdownMenuItem<String>> studentItems = [];
        for (var doc in snapshot.data!.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String name = data['name'] ?? 'Tanpa Nama';
          String uid = doc.id; 

          studentItems.add(
            DropdownMenuItem(
              value: uid, 
              child: Text(name, style: TextStyle(color: textDark)),
            ),
          );
        }

        // 4. Render
        return _buildInputContainer(
          context,
          child: DropdownButtonFormField<String>(
            decoration: _inputDecoration("Pilih Siswa", Icons.person_search_rounded),
            value: selectedStudentId,
            isExpanded: true,
            dropdownColor: Colors.white,
            hint: Text("Klik untuk memilih siswa", style: TextStyle(color: textGrey)),
            icon: Icon(Icons.arrow_drop_down_circle, color: rgPrimary),
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

  // --- BUILDER: TEXT FIELD ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return _buildInputContainer(
      context,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Wajib diisi';
          if (isNumber && double.tryParse(value) == null) return 'Harus angka';
          return null;
        },
        style: TextStyle(fontWeight: FontWeight.w500, color: textDark),
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradeProv = Provider.of<GradeProvider>(context, listen: false);

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
          'Input Nilai Siswa', 
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAGIAN 1: SISWA ---
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  "Identitas", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)
                ),
              ),
              
              _buildStudentDropdown(context),

              _buildTextField(
                controller: subjectC, 
                label: 'Mata Pelajaran', 
                icon: Icons.menu_book_rounded
              ),

              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade300, height: 30),
              const SizedBox(height: 10),
              
              // --- BAGIAN 2: NILAI ---
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  "Komponen Nilai", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)
                ),
              ),

              _buildTextField(
                controller: tugasC, 
                label: 'Nilai Tugas', 
                icon: Icons.assignment_outlined, 
                isNumber: true
              ),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: utsC, 
                      label: 'Nilai UTS', 
                      icon: Icons.fact_check_outlined, 
                      isNumber: true
                    )
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      controller: uasC, 
                      label: 'Nilai UAS', 
                      icon: Icons.history_edu_outlined, 
                      isNumber: true
                    )
                  ),
                ],
              ),
              
              const SizedBox(height: 30),

              // --- TOMBOL SIMPAN (GANTI WARNA JADI BIRU/CYAN) ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rgDark, // Menggunakan Biru/Cyan Tua agar kontras
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: rgDark.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            SnackBar(
                              content: const Text('Nilai berhasil disimpan!'),
                              backgroundColor: rgPrimary, // SnackBar Cyan
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          // Reset Form
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
                  child: const Text(
                    'Simpan Data Nilai', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
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