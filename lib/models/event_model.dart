// models/event_model.dart

class EventModel {
  final int id;
  final String title;
  final String description;
  final String startDate;
  final String? endDate;
  final String? time;
  final String location;
  final num? price;
  final int maxParticipants;
  final int currentParticipants;
  final String category;
  final int? creatorId;
  final String? icon; 
  final String? color;

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
    String formatDate(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) return '';
      try {
        return dateTimeString.split('T')[0];
      } catch (e) {
        return dateTimeString;
      }
    }

    return EventModel(
      id: json['id'] ?? 0,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? 'No Description',
      startDate: formatDate(json['start_date'] as String?),
      endDate: formatDate(json['end_date'] as String?),
      time: json['time'] as String?,
      location: json['location'] as String? ?? 'No Location',
      price: json['price'] as num?,
      maxParticipants: json['max_attendees'] as int? ?? 0,
      currentParticipants: json['registrations_count'] as int? ?? 0,
      category: json['category'] as String? ?? 'Uncategorized',
      creatorId: (json['creator'] as Map<String, dynamic>?)?['id'],
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }
}
