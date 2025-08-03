// lib/providers/event_provider.dart

import 'package:flutter/material.dart';
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

  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _events = await _apiService.getEvents();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // REVISI: Menambahkan parameter 'icon' yang dibutuhkan
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
    required String icon, // <-- Parameter yang hilang ditambahkan di sini
    required String color,
  }) async {
    try {
      await _apiService.createEvent(
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        time: time,
        location: location,
        maxAttendees: maxAttendees,
        price: price,
        category: category,
        token: token,
        icon: icon, // <-- Meneruskan icon ke ApiService
        color: color,
      );
      await fetchEvents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> updateExistingEvent(int eventId, Map<String, dynamic> eventData, String token) async {
    try {
      await _apiService.updateEvent(eventId, eventData, token);
      await fetchEvents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      return false;
    }
  }
}
