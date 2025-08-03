import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/event_model.dart';
import 'package:uas/providers/auth_provider.dart';
import 'package:uas/providers/event_provider.dart';
import 'package:uas/screens/home/edit_event_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Event'),
        content: Text('Apakah Anda yakin ingin menghapus event "${event.title}"?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              Provider.of<EventProvider>(context, listen: false)
                  .deleteExistingEvent(event.id, authProvider.token!)
                  .then((success) {
                Navigator.of(ctx).pop(); // Tutup dialog
                if (success) {
                  Navigator.of(context).pop(); // Kembali ke home screen
                }
              });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditEventScreen(event: event),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.category, 'Kategori', event.category),
            _buildDetailRow(Icons.location_on, 'Lokasi', event.location),
            _buildDetailRow(Icons.calendar_today, 'Tanggal Mulai', event.startDate),
            if (event.endDate != null && event.endDate!.isNotEmpty)
              _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal Selesai', event.endDate!),
            if (event.time != null && event.time!.isNotEmpty)
              _buildDetailRow(Icons.access_time, 'Waktu', event.time!),
            _buildDetailRow(Icons.people, 'Kapasitas', '${event.currentParticipants} / ${event.maxParticipants}'),
            if (event.price != null)
              _buildDetailRow(Icons.attach_money, 'Harga', 'Rp ${event.price}'),
            const SizedBox(height: 24),
            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
