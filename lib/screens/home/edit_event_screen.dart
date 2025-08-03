import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/event_model.dart';
import 'package:uas/providers/auth_provider.dart';
import 'package:uas/providers/event_provider.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  late TextEditingController _maxAttendeesController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  String? _selectedIcon;
  Color _selectedColor = Colors.indigo;

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _startDateController = TextEditingController(text: widget.event.startDate);
    _endDateController = TextEditingController(text: widget.event.endDate ?? '');
    _timeController = TextEditingController(text: widget.event.time ?? '00:00:00');
    _locationController = TextEditingController(text: widget.event.location);
    _maxAttendeesController = TextEditingController(text: widget.event.maxParticipants.toString());
    _priceController = TextEditingController(text: widget.event.price?.toString() ?? '0');
    _categoryController = TextEditingController(text: widget.event.category);
    _selectedIcon = widget.event.icon ?? 'event';
    _selectedColor = _hexToColor(widget.event.color) ?? Colors.indigo;
  }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final eventData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'start_date': _startDateController.text,
      'end_date': _endDateController.text,
      'time': _timeController.text,
      'location': _locationController.text,
      'max_attendees': int.tryParse(_maxAttendeesController.text) ?? 0,
      'price': num.tryParse(_priceController.text) ?? 0,
      'category': _categoryController.text,
      'icon': _selectedIcon,
      'color': '#${_selectedColor.value.toRadixString(16).substring(2)}',
    };

    bool success = await eventProvider.updateExistingEvent(widget.event.id, eventData, authProvider.token!);

    if (context.mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui event.'), backgroundColor: Colors.red),
        );
      }
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
        title: const Text('Edit Event'),
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
                onPressed: _submitUpdate,
                icon: const Icon(Icons.save_as),
                label: const Text('SIMPAN PERUBAHAN'),
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
        Text('Warna Latar Ikon', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
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

  Color? _hexToColor(String? hexColor) {
    if (hexColor == null) return null;
    final hexCode = hexColor.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    return null;
  }
}
