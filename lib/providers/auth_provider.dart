// lib/providers/auth_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // REVISI: Menggunakan path relatif
import '../models/user_model.dart';   // REVISI: Menggunakan path relatif

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token;
  UserModel? _user;

  String? get token => _token;
  UserModel? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;

  /// Logs in a user and saves the session.
  Future<bool> login(String studentNumber, String password) async {
    try {
      final responseData = await _apiService.login(studentNumber, password);

      if (responseData['success'] == true && responseData['data'] != null) {
        _token = responseData['data']['token'];
        _user = UserModel.fromJson(responseData['data']['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_user!.toJson()));

        notifyListeners();
        return true;
      } else {
        // Memberikan log yang lebih informatif jika login gagal dari sisi server
        debugPrint('[Login Failed] Server message: ${responseData['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('[Login Error] Exception caught: $e');
      return false;
    }
  }

  /// Registers a new user.
  Future<bool> register({
    required String name,
    required String email,
    required String studentNumber,
    required String major,
    required int classYear,
    required String password,
  }) async {
    try {
      final result = await _apiService.register(
        name: name,
        email: email,
        studentNumber: studentNumber,
        major: major,
        classYear: classYear,
        password: password,
      );
      // Memeriksa flag 'success' dari respon API
      return result['success'] == true;
    } catch (e) {
      debugPrint('[Register Error] Exception caught: $e');
      return false;
    }
  }

  /// Logs out the current user and clears the session.
  Future<void> logout() async {
    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    notifyListeners();
  }

  /// Tries to automatically log in the user from stored credentials.
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('token') || !prefs.containsKey('user')) {
      return false;
    }

    try {
      _token = prefs.getString('token');
      _user = UserModel.fromJson(jsonDecode(prefs.getString('user')!));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AutoLogin Error] Failed to parse stored user data: $e');
      // Jika data user corrupt, hapus session agar tidak terjadi loop error
      await logout();
      return false;
    }
  }
}
