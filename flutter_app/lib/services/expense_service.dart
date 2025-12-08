import 'package:dio/dio.dart';
import '../models/expense.dart';
import '../models/summary.dart';
import 'api_service.dart';

class ExpenseService {
  final Dio _dio = ApiService().client;

  Future<List<Expense>> getExpenses(String eventCode) async {
    try {
      final response = await _dio.get('/expense/list/$eventCode');
      final List data = response.data['data']['expenses'];
      return data.map((e) => Expense.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Expense> createExpense(int eventId, String title, double amount, String? note) async {
    try {
      final response = await _dio.post('/expense/$eventId', data: {
        'title': title,
        'amount': amount,
        'note': note,
      });
      return Expense.fromJson(response.data['data']['expense']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Expense> updateExpense(int expenseId, String title, double amount, String? note) async {
    try {
      final response = await _dio.put('/expense/$expenseId', data: {
        'title': title,
        'amount': amount,
        'note': note,
      });
      return Expense.fromJson(response.data['data']['expense']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Expense> updateExpenseStatus(int expenseId, String status) async {
    try {
      final response = await _dio.put('/expense/$expenseId/status', data: {
        'status': status,
      });
      return Expense.fromJson(response.data['data']['expense']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<EventSummary> getEventSummary(String eventCode) async {
    try {
      final response = await _dio.get('/event/summery/$eventCode');
      return EventSummary.fromJson(response.data['data']);
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
