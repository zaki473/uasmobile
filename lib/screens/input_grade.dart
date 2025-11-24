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
  Widget _buildInputContainer(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        // Warna background container (Putih di Light, Abu Gelap di Dark)
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // Shadow lebih tipis di dark mode
            color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        // Border tipis untuk dark mode agar container terlihat jelas
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.indigoAccent : Colors.indigoAccent;
    final labelColor = isDark ? Colors.white70 : Colors.grey[600];

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: labelColor, fontSize: 14),
      prefixIcon: Icon(icon, color: iconColor),
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

  // --- BUILDER: DROPDOWN SISWA ---
  Widget _buildStudentDropdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'siswa') 
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Handle Loading
        if (!snapshot.hasData) {
          return _buildInputContainer(
            context,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 15),
                  Text("Memuat data siswa...", style: TextStyle(color: textColor)),
                ],
              ),
            ),
          );
        }

        // 2. Handle Error / Kosong
        if (snapshot.hasError) {
           return _buildInputContainer(context, child: ListTile(title: Text("Error: ${snapshot.error}", style: TextStyle(color: textColor))));
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

        // 3. Buat List Dropdown Item
        List<DropdownMenuItem<String>> studentItems = [];
        for (var doc in snapshot.data!.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          String name = data['name'] ?? 'Tanpa Nama';
          String uid = doc.id; 

          studentItems.add(
            DropdownMenuItem(
              value: uid, 
              child: Text(
                name, 
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor), // Warna teks item dropdown
              ),
            ),
          );
        }

        // 4. Render Dropdown
        return _buildInputContainer(
          context,
          child: DropdownButtonFormField<String>(
            decoration: _inputDecoration(context, "Pilih Siswa", Icons.person_search_outlined),
            value: selectedStudentId,
            isExpanded: true,
            dropdownColor: isDark ? Theme.of(context).cardColor : Colors.white, // <-- PENTING: Warna menu dropdown
            hint: Text("Klik untuk memilih siswa", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
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
  Widget _buildTextField(BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return _buildInputContainer(
      context,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return '$label tidak boleh kosong';
          if (isNumber && double.tryParse(value) == null) return 'Harus angka';
          return null;
        },
        // Warna teks input
        style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87),
        decoration: _inputDecoration(context, label, icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradeProv = Provider.of<GradeProvider>(context, listen: false);

    // 1. Deteksi Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 2. Tentukan Warna UI
    final bgColor = isDark ? null : const Color(0xFFF5F7FA);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final headingColor = isDark ? Colors.indigoAccent : Colors.indigo;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Input Nilai Siswa', 
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 15),
                child: Text(
                  "Identitas Siswa", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: headingColor)
                ),
              ),
              
              _buildStudentDropdown(context), // DROPDOWN

              _buildTextField(context, controller: subjectC, label: 'Mata Pelajaran', icon: Icons.menu_book_rounded),

              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 15),
                child: Text(
                  "Input Penilaian", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: headingColor)
                ),
              ),

              _buildTextField(context, controller: tugasC, label: 'Nilai Tugas', icon: Icons.assignment_outlined, isNumber: true),
              
              Row(
                children: [
                  Expanded(child: _buildTextField(context, controller: utsC, label: 'Nilai UTS', icon: Icons.fact_check_outlined, isNumber: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField(context, controller: uasC, label: 'Nilai UAS', icon: Icons.history_edu_outlined, isNumber: true)),
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
                    foregroundColor: Colors.white,
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
                  child: const Text('Simpan Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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