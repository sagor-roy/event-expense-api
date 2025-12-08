import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/summary.dart';
import '../services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];
  EventSummary? _summary;
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  EventSummary? get summary => _summary;
  bool get isLoading => _isLoading;

  Future<void> fetchExpenses(String eventCode) async {
    _isLoading = true;
    notifyListeners();
    try {
      _expenses = await _expenseService.getExpenses(eventCode);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createExpense(int eventId, String title, double amount, String? note) async {
    try {
      final newExpense = await _expenseService.createExpense(eventId, title, amount, note);
      _expenses.add(newExpense);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateExpense(int expenseId, String title, double amount, String? note) async {
    try {
      final updatedExpense = await _expenseService.updateExpense(expenseId, title, amount, note);
      final index = _expenses.indexWhere((e) => e.id == expenseId);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateExpenseStatus(int expenseId, String status) async {
    try {
      final updatedExpense = await _expenseService.updateExpenseStatus(expenseId, status);
      final index = _expenses.indexWhere((e) => e.id == expenseId);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchSummary(String eventCode) async {
    try {
      _summary = await _expenseService.getEventSummary(eventCode);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
