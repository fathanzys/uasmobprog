// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class ApiService {
  final String _baseUrl = "http://103.160.63.165/api";

  Future<Map<String, dynamic>> login(String studentNumber, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'student_number': studentNumber, 'password': password}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to login. Status: ${response.statusCode}, Body: ${response.body}');
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String studentNumber,
    required String major,
    required int classYear,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'student_number': studentNumber,
        'major': major,
        'class_year': classYear,
        'password': password,
        'password_confirmation': password,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<List<EventModel>> getEvents() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse('$_baseUrl/events?cache_buster=$timestamp');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['data'] is Map && decoded['data']['events'] is List) {
        final data = decoded['data']['events'] as List;
        return data.map((item) => EventModel.fromJson(item)).toList();
      } else {
        throw Exception('Invalid data format for events.');
      }
    }
    throw Exception('Failed to load events');
  }

  // REVISI: Menambahkan kembali parameter 'icon'
  Future<void> createEvent({
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    required String time,
    required String location,
    required int maxAttendees,
    required num price,
    required String category,
    required String token,
    required String icon, // <-- Parameter ditambahkan kembali
    required String color,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'time': time,
        'location': location,
        'max_attendees': maxAttendees,
        'price': price,
        'category': category,
        'icon': icon, // <-- Mengirimkan icon ke server
        'color': color,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create event. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<void> updateEvent(int eventId, Map<String, dynamic> eventData, String token) async {
    // REVISI: Tidak lagi menghapus 'icon'
    final response = await http.put(
      Uri.parse('$_baseUrl/events/$eventId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: jsonEncode(eventData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update event. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<void> deleteEvent(int eventId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/events/$eventId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete event. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
