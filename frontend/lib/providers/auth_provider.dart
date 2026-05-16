import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../utils/constants.dart';
import 'notification_provider.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? user;
  bool isLoading = false;
  String? _token;

  String? get token => _token;

  // ✅ Load token from local storage on startup
  Future<void> loadUserFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  _token = prefs.getString('token');
  if (_token == null) return;

  final res = await http.get(
    Uri.parse("${ApiConstants.baseUrl}/auth/me"),
    headers: {"Authorization": "Bearer $_token"},
  );

  if (res.statusCode == 200) {
    user = User.fromJson(json.decode(res.body));

    SocketService.connect(user!.id, (data) {
      final np = Provider.of<NotificationProvider>(
        navigatorKey.currentContext!,
        listen: false,
      );
      np.prependFromSocket(data);
    });
  }

  notifyListeners();
}


  Future<void> _saveFcmToken(String userId) async {
  String? token = await FirebaseMessaging.instance.getToken();
  if (token == null) return;

  await http.post(
    Uri.parse("${ApiConstants.baseUrl}/auth/save-fcm-token"),
    headers: {"Content-Type": "application/json"},
    body: json.encode({"userId": userId, "token": token}),
  );
}

  Future<Map<String, dynamic>> register(
      String name, String email, String gstNumber, File? gstDocument) async {
    isLoading = true;
    notifyListeners();

    final response = await _apiService.registerUser(name, email, gstNumber, gstDocument);

    isLoading = false;
    notifyListeners();
    return response;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
  isLoading = true;
  notifyListeners();

  final response = await _apiService.loginUser(email, password);

  if (response.containsKey('token')) {
  _token = response['token'];
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', _token!);

  user = User(
    id: response['_id'],
    name: response['name'],
    email: email,
    isApproved: true,
  );

  await _saveFcmToken(user!.id);

  SocketService.connect(user!.id, (data) {
    final np = Provider.of<NotificationProvider>(
      navigatorKey.currentContext!,
      listen: false,
    );
    np.prependFromSocket(data);
  });

  notifyListeners();
}


  isLoading = false;
  notifyListeners();
  return response;
}


  Future<Map<String, dynamic>> forgotPassword(String email) async {
    isLoading = true;
    notifyListeners();

    final response = await _apiService.forgotPassword(email);

    isLoading = false;
    notifyListeners();
    return response;
  }

  // ✅ Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    user = null;
    _token = null;
    notifyListeners();
  }
}
