import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Pastikan path import ini benar sesuai folder Anda

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controller
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final linkedIdC = TextEditingController();

  // State
  bool isLoading = false;
  String selectedRole = 'student'; // Default role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Tambah Akun Baru',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buat akun untuk Admin atau Siswa agar mereka bisa login ke aplikasi.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // --- PILIHAN ROLE ---
              _buildInputContainer(
                child: DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: _inputDecoration("Pilih Role User", Icons.verified_user),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Siswa')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin / Guru')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      selectedRole = val!;
                    });
                  },
                ),
              ),

              // --- FORM INPUT ---
              _buildTextField(nameC, 'Nama Lengkap', Icons.person),
              const SizedBox(height: 15),
              _buildTextField(emailC, 'Email', Icons.email, inputType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildTextField(passC, 'Password', Icons.lock, isObscure: true),
              const SizedBox(height: 15),
              _buildTextField(
                linkedIdC, 
                selectedRole == 'student' ? 'NISN / NIS' : 'Kode Admin / NIP', 
                Icons.badge
              ),

              const SizedBox(height: 30),

              // --- TOMBOL SIMPAN ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  onPressed: isLoading ? null : _handleSubmit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Buat Akun',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // Panggil AuthService yang baru Anda update
      String? error = await _authService.registerUser(
        email: emailC.text.trim(),
        password: passC.text.trim(),
        name: nameC.text.trim(),
        role: selectedRole,
        linkedId: linkedIdC.text.trim(),
      );

      setState(() => isLoading = false);

      if (mounted) {
        if (error == null) {
          // SUKSES
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("✅ User berhasil dibuat! Otomatis masuk Database."),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Reset Form
          nameC.clear();
          emailC.clear();
          passC.clear();
          linkedIdC.clear();
        } else {
          // GAGAL
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Gagal: $error"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // --- STYLING HELPER (Sama dengan design Anda sebelumnya) ---
  Widget _buildInputContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon, {bool isObscure = false, TextInputType inputType = TextInputType.text}) {
    return _buildInputContainer(
      child: TextFormField(
        controller: c,
        obscureText: isObscure,
        keyboardType: inputType,
        validator: (val) => val!.isEmpty ? '$label wajib diisi' : null,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.indigoAccent),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.indigo, width: 1.5)),
    );
  }
}