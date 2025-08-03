// lib/models/event_model.dart

class EventModel {
  final int id;
  final String title;
  final String description;
  final String startDate;
  final String? endDate;
  final String? time;      // Tetap ada di model, tapi tidak akan diisi dari JSON ini
  final String location;
  final num? price;
  final int maxParticipants;
  final int currentParticipants;
  final String category;
  final int? creatorId;
  final String? icon;      // Tetap ada di model, tapi tidak akan diisi dari JSON ini
  final String? color;     // Tetap ada di model, tapi tidak akan diisi dari JSON ini

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    this.time,
    required this.location,
    this.price,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.category,
    this.creatorId,
    this.icon,
    this.color,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Fungsi kecil untuk memformat tanggal dari format '2025-07-31T18:00:00...' menjadi '2025-07-31'
    String formatDate(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) return 'Tanggal tidak tersedia';
      try {
        return dateTimeString.split('T')[0];
      } catch (e) {
        return dateTimeString; // Kembalikan string asli jika formatnya tidak terduga
      }
    }

    // --- PERUBAHAN UTAMA DI SINI ---
    // Kita hanya mem-parsing field yang benar-benar ada di JSON
    return EventModel(
      id: json['id'] ?? 0,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? 'No Description',
      startDate: formatDate(json['start_date'] as String?),
      endDate: formatDate(json['end_date'] as String?),
      location: json['location'] as String? ?? 'No Location',
      price: json['price'] as num?,
      maxParticipants: json['max_attendees'] as int? ?? 0,
      currentParticipants: json['registrations_count'] as int? ?? 0,
      category: json['category'] as String? ?? 'Uncategorized',
      creatorId: (json['creator'] as Map<String, dynamic>?)?['id'],

      // Field di bawah ini tidak ada di JSON /events Anda, jadi kita set ke null.
      // Ini mencegah error parsing.
      time: json['time'] as String?, // API Anda mengirim start_date yang berisi waktu
      icon: json['icon'] as String?, // Tidak ada 'icon' di JSON
      color: json['color'] as String?, // Tidak ada 'color' di JSON
    );
  }
}