import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _majorController = TextEditingController();
  final _classYearController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    final fields = [
      _nameController.text,
      _emailController.text,
      _studentNumberController.text,
      _majorController.text,
      _classYearController.text,
      _passwordController.text
    ];

    if (fields.any((field) => field.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field harus diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final classYear = int.tryParse(_classYearController.text);
    if (classYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tahun Angkatan harus berupa angka yang valid.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await Provider.of<AuthProvider>(context, listen: false).register(
      name: _nameController.text,
      email: _emailController.text,
      studentNumber: _studentNumberController.text,
      major: _majorController.text,
      classYear: classYear,
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registrasi Berhasil! Silakan login.'),
            backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registrasi Gagal. Periksa kembali data Anda.'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dibuat transparan agar menyatu dengan gradien
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      // Agar AppBar dan body menyatu, extend body ke belakang AppBar
      extendBodyBehindAppBar: true,
      body: Container(
        // Latar belakang gradien utama
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3A2D7D),
              Color(0xFF5C45A0),
              Color(0xFF8161C6),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Ikon roket yang sesuai tema
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.rocket_launch_outlined, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selamat Datang di HackVerse',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Satu langkah lagi menuju event seru!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                _buildInputField(controller: _nameController, label: 'Nama Lengkap', icon: Icons.badge),
                const SizedBox(height: 16),
                _buildInputField(controller: _emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildInputField(controller: _studentNumberController, label: 'Nomor Mahasiswa', icon: Icons.person, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildInputField(controller: _majorController, label: 'Jurusan', icon: Icons.school),
                const SizedBox(height: 16),
                _buildInputField(controller: _classYearController, label: 'Tahun Angkatan', icon: Icons.calendar_today, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildInputField(controller: _passwordController, label: 'Password', icon: Icons.lock, obscureText: true),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _buildGradientButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tombol dengan efek gradien
  Widget _buildGradientButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E71D6), Color(0xFF6A53B4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'DAFTAR AKUN',
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Input field dengan gaya modern
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white), // Warna teks input
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), // Warna latar field semi-transparan
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}