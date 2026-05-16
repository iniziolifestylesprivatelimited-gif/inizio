import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockProvider extends ChangeNotifier {
  bool _isAppLockEnabled = false;

  bool get isAppLockEnabled => _isAppLockEnabled;

bool isLoaded = false;

Future<void> loadLockSetting() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _isAppLockEnabled = prefs.getBool("app_lock_enabled") ?? false;
  isLoaded = true;
  notifyListeners();
}


  Future<void> toggleAppLock(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAppLockEnabled = value;
    await prefs.setBool("app_lock_enabled", value);
    notifyListeners();
  }
}
