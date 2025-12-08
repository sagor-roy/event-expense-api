import 'package:dio/dio.dart';
import '../models/event.dart';
import '../models/join_request.dart';
import '../models/user.dart';
import 'api_service.dart';

class EventService {
  final Dio _dio = ApiService().client;

  Future<List<Event>> getEvents() async {
    try {
      final response = await _dio.get('/event');
      final List data = response.data['data']['events'];
      return data.map((e) => Event.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Event> createEvent(String name, String eventCode, String? description) async {
    try {
      final response = await _dio.post('/event', data: {
        'name': name,
        'event_code': eventCode,
        'description': description,
      });
      // The 'store' API returns the raw event model, which lacks 'owner' (string) and 'members_count'.
      // We manually construct the Event object to match our local model expectations.
      final rawEvent = response.data['data']['event'];
      
      // Format date if needed, or just use the string. 
      // The API 'index' returns 'd-M-Y', but 'store' returns ISO. 
      // For consistency, we might want to format it, but for now let's just use the raw string 
      // or a simple substring if it's ISO.
      String createdAt = rawEvent['created_at'];
      try {
        // Simple attempt to match 'd-M-Y' format if it's ISO
        // final date = DateTime.parse(createdAt);
        // We don't have intl here easily without import, but we can do simple string manipulation
        // or just leave it. Let's leave it as is, or import intl.
        // Actually, let's just use the raw string.
      } catch (_) {}

      return Event(
        id: rawEvent['id'],
        name: rawEvent['name'],
        eventCode: rawEvent['event_code'],
        owner: 'You', // We created it
        description: rawEvent['description'],
        membersCount: 1, // Just us
        createdAt: createdAt,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ... (updateEvent, deleteEvent, etc. remain unchanged)

  Future<Event> updateEvent(int id, String name, String? description) async {
    try {
      final response = await _dio.put('/event/$id', data: {
        'name': name,
        'description': description,
      });
      // Update also returns raw event. We might need to handle this too if we use the return value.
      // But usually update doesn't change owner or members_count.
      final rawEvent = response.data['data']['event'];
      return Event(
        id: rawEvent['id'],
        name: rawEvent['name'],
        eventCode: rawEvent['event_code'],
        owner: 'You', // Only owner can update, so it must be 'You'
        description: rawEvent['description'],
        membersCount: 0, // We don't know this from update response. 
        // Ideally we shouldn't rely on this return for the list view without refreshing.
        // But let's return a safe object.
        createdAt: rawEvent['created_at'],
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await _dio.delete('/event/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> joinEvent(String eventCode) async {
    try {
      await _dio.post('/join/$eventCode');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<JoinRequest>> getJoinRequests(String eventCode) async {
    try {
      final response = await _dio.get('/join/request_list/$eventCode');
      final List data = response.data['data']['requests'];
      return data.map((e) => JoinRequest.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> acceptJoinRequest(String eventCode, int requestId) async {
    try {
      await _dio.post('/join/$eventCode/$requestId/accept');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> rejectJoinRequest(String eventCode, int requestId) async {
    try {
      await _dio.post('/join/$eventCode/$requestId/reject');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<User>> getMembers(String eventCode) async {
    try {
      final response = await _dio.get('/event/members/$eventCode');
      final List data = response.data['data']['members'];
      return data.map((e) => User.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        // Check for validation errors in 'data' field
        if (data is Map && data.containsKey('data')) {
           final errors = data['data'];
           if (errors is Map) {
             String messages = '';
             errors.forEach((key, value) {
               if (value is List) {
                 messages += value.join('\n') + '\n';
               } else {
                 messages += value.toString() + '\n';
               }
             });
             if (messages.isNotEmpty) return messages.trim();
           }
        }
        return data['message'] ?? e.message ?? 'An error occurred';
      }
      return e.message ?? 'An error occurred';
    }
    return e.toString();
  }
}
