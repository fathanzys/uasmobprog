// lib/providers/event_provider.dart

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<EventModel> _events = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // REVISI: Fungsi ini sekarang wajib menerima token
  Future<void> fetchEvents(String token) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _events = await _apiService.getEvents(token);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[Fetch Events Error] $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createNewEvent({
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
    required String icon,
    required String color,
  }) async {
    try {
      await _apiService.createEvent(
        title: title, description: description, startDate: startDate,
        endDate: endDate, time: time, location: location,
        maxAttendees: maxAttendees, price: price, category: category,
        token: token, icon: icon, color: color,
      );
      // REVISI: Kirimkan token saat refresh data
      await fetchEvents(token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[Create Event Error] $e');
      return false;
    }
  }

  Future<bool> updateExistingEvent(int eventId, Map<String, dynamic> eventData, String token) async {
    try {
      await _apiService.updateEvent(eventId, eventData, token);
      // REVISI: Kirimkan token saat refresh data
      await fetchEvents(token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[Update Event Error] $e');
      return false;
    }
  }

  Future<bool> deleteExistingEvent(int eventId, String token) async {
    try {
      await _apiService.deleteEvent(eventId, token);
      _events.removeWhere((event) => event.id == eventId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[Delete Event Error] $e');
      return false;
    }
  }
}
