import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas/providers/auth_provider.dart';
import 'package:uas/providers/event_provider.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  String? _selectedIcon = 'event';
  Color _selectedColor = Colors.indigo;

  bool _isLoading = false;

  final Map<String, IconData> _iconOptions = {
    'event': Icons.event,
    'computer': Icons.computer,
    'build': Icons.build,
    'groups': Icons.groups,
    'people': Icons.people,
    'emoji_events': Icons.emoji_events,
    'school': Icons.school,
    'book': Icons.book,
    'mosque': Icons.mosque,
  };

  final List<Color> _colorOptions = [
    Colors.indigo, Colors.blue, Colors.teal, Colors.green,
    Colors.amber, Colors.orange, Colors.red, Colors.purple, Colors.pink,
  ];

  void _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final maxAttendees = int.tryParse(_maxAttendeesController.text) ?? 0;
    final price = num.tryParse(_priceController.text) ?? 0;

    bool success = await eventProvider.createNewEvent(
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDateController.text,
      endDate: _endDateController.text,
      time: _timeController.text,
      location: _locationController.text,
      maxAttendees: maxAttendees,
      price: price,
      category: _categoryController.text,
      token: authProvider.token!,
      icon: _selectedIcon ?? 'event',
      color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
    );

    if (context.mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Event berhasil dibuat!' : 'Gagal membuat event.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Event Baru'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Detail Utama'),
              _buildTextField(controller: _titleController, label: 'Judul Event', icon: Icons.title),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIcon,
                decoration: const InputDecoration(
                  labelText: 'Ikon Event',
                  prefixIcon: Icon(Icons.emoji_emotions),
                  border: OutlineInputBorder(),
                ),
                items: _iconOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value, color: Colors.indigo),
                        const SizedBox(width: 10),
                        Text(entry.key[0].toUpperCase() + entry.key.substring(1)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedIcon = value),
              ),
              const SizedBox(height: 16),
              _buildColorPicker(),
              const SizedBox(height: 24),

              _buildSectionTitle('Jadwal & Lokasi'),
              _buildTextField(controller: _startDateController, label: 'Tanggal Mulai (YYYY-MM-DD)', icon: Icons.calendar_today),
              const SizedBox(height: 16),
              _buildTextField(controller: _endDateController, label: 'Tanggal Selesai (Opsional)', icon: Icons.calendar_today_outlined, isRequired: false),
              const SizedBox(height: 16),
              _buildTextField(controller: _timeController, label: 'Waktu (HH:MM:SS)', icon: Icons.access_time, isRequired: false),
              const SizedBox(height: 16),
              _buildTextField(controller: _locationController, label: 'Lokasi', icon: Icons.location_on),
              const SizedBox(height: 24),

              _buildSectionTitle('Kapasitas & Harga'),
              _buildTextField(controller: _maxAttendeesController, label: 'Maksimal Peserta', icon: Icons.people, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(controller: _priceController, label: 'Harga (0 jika gratis)', icon: Icons.attach_money, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(controller: _categoryController, label: 'Kategori', icon: Icons.category),
              const SizedBox(height: 32),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _submitEvent,
                icon: const Icon(Icons.add_task),
                label: const Text('SUBMIT EVENT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Warna Latar', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _colorOptions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final color = _colorOptions[index];
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo.shade300),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: true,
        fillColor: Colors.indigo.withOpacity(0.05),
      ),
      keyboardType: keyboardType,
      validator: isRequired ? (v) => v!.isEmpty ? 'Wajib diisi' : null : null,
    );
  }
}
