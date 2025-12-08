import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.login(email, password);
      if (data['status'] == 'success') {
        _token = data['data']['token'];
        _user = User.fromJson(data['data']['user']);
        await _saveToken(_token!);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.register(name, email, password, confirmPassword);
      if (data['status'] == 'success') {
        _token = data['data']['token'];
        _user = User.fromJson(data['data']['user']);
        await _saveToken(_token!);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    if (_user != null) {
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    _token = prefs.getString('token');
    if (prefs.containsKey('user_data')) {
      try {
        _user = User.fromJson(jsonDecode(prefs.getString('user_data')!));
      } catch (e) {
        // Failed to parse user data
      }
    }
    notifyListeners();
  }
}
