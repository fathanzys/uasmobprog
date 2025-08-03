import 'package:flutter/foundation.dart';
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

  Future<void> fetchEvents(String token) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final fetchedEvents = await _apiService.getEvents(token);
      _events = fetchedEvents;
    } catch (e) {
      _errorMessage = '[Fetch Events Error]: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        icon: icon,
        color: color,
      );
      await fetchEvents(token); // Refresh setelah create
      return true;
    } catch (e) {
      _errorMessage = '[Create Event Error]: ${e.toString()}';
      return false;
    }
  }

  Future<bool> updateExistingEvent(int eventId, Map<String, dynamic> eventData, String token) async {
    try {
      await _apiService.updateEvent(eventId, eventData, token);
      await fetchEvents(token); // Refresh setelah update
      return true;
    } catch (e) {
      _errorMessage = '[Update Event Error]: ${e.toString()}';
      return false;
    }
  }

  Future<bool> deleteExistingEvent(int eventId, String token) async {
    try {
      await _apiService.deleteEvent(eventId, token);
      _events.removeWhere((event) => event.id == eventId); // Local delete
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '[Delete Event Error]: ${e.toString()}';
      return false;
    }
  }
}
