import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final _api = ApiService();
  final List<NotificationItem> _items = [];
  bool _loading = false;

  List<NotificationItem> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.isRead).length;
  bool get loading => _loading;

  Future<void> load(String token) async {
    _loading = true; notifyListeners();
    try {
      final list = await _api.fetchNotifications(token);
      _items
        ..clear()
        ..addAll(list.map((e) => NotificationItem.fromJson(e)));
    } finally {
      _loading = false; notifyListeners();
    }
  }

  // called when socket pushes a new notification
  void prependFromSocket(Map data) {
    final n = NotificationItem.fromJson(Map<String, dynamic>.from(data));
    _items.insert(0, n);
    notifyListeners();
  }

  Future<void> markRead(String id, String token) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    if (!_items[idx].isRead) {
      _items[idx] = NotificationItem(
        id: _items[idx].id,
        title: _items[idx].title,
        message: _items[idx].message,
        isRead: true,
        createdAt: _items[idx].createdAt,
      );
      notifyListeners();
    }
    await _api.markNotificationRead(id, token);
  }
}
