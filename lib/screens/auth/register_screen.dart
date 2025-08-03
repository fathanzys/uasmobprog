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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person_add, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Buat Akun HackVerse',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            const SizedBox(height: 32),
            _buildInputCard(controller: _nameController, label: 'Nama Lengkap', icon: Icons.badge),
            const SizedBox(height: 16),
            _buildInputCard(controller: _emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildInputCard(controller: _studentNumberController, label: 'Nomor Mahasiswa', icon: Icons.person, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildInputCard(controller: _majorController, label: 'Jurusan', icon: Icons.school),
            const SizedBox(height: 16),
            _buildInputCard(controller: _classYearController, label: 'Tahun Angkatan', icon: Icons.calendar_today, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildInputCard(controller: _passwordController, label: 'Password', icon: Icons.lock, obscureText: true),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'DAFTAR',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
