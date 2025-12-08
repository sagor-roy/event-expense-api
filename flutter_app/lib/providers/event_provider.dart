import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/join_request.dart';
import '../models/user.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  bool _isLoading = false;
  
  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();
    try {
      _events = await _eventService.getEvents();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createEvent(String name, String eventCode, String? description) async {
    try {
      final newEvent = await _eventService.createEvent(name, eventCode, description);
      _events.add(newEvent);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(int id, String name, String? description) async {
    try {
      final updatedEvent = await _eventService.updateEvent(id, name, description);
      final index = _events.indexWhere((e) => e.id == id);
      if (index != -1) {
        _events[index] = updatedEvent;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await _eventService.deleteEvent(id);
      _events.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> joinEvent(String eventCode) async {
    try {
      await _eventService.joinEvent(eventCode);
    } catch (e) {
      rethrow;
    }
  }

  // Helper for specific event data
  Future<List<JoinRequest>> fetchJoinRequests(String eventCode) async {
    return await _eventService.getJoinRequests(eventCode);
  }

  Future<void> acceptJoinRequest(String eventCode, int requestId) async {
    await _eventService.acceptJoinRequest(eventCode, requestId);
    notifyListeners(); // Maybe refresh something?
  }

  Future<void> rejectJoinRequest(String eventCode, int requestId) async {
    await _eventService.rejectJoinRequest(eventCode, requestId);
    notifyListeners();
  }

  Future<List<User>> fetchMembers(String eventCode) async {
    return await _eventService.getMembers(eventCode);
  }
}
