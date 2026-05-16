import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ChatProvider extends ChangeNotifier {
  IO.Socket? socket;

  /// normalized
  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  bool _isTypingFromPeer = false;
  bool get isTypingFromPeer => _isTypingFromPeer;

  String? _meId;
  String? _peerId;
  String? _token;

  void _normalizeAndAppend(dynamic raw) {
    final m = <String, dynamic>{};
    m["_id"] = (raw["_id"] ?? "").toString();
    final snd = raw["sender"];
    final rcv = raw["receiver"];
    m["sender"] = snd is Map ? (snd["_id"] ?? snd["id"]).toString() : snd.toString();
    m["receiver"] = rcv is Map ? (rcv["_id"] ?? rcv["id"]).toString() : rcv.toString();
    m["message"] = (raw["message"] ?? "").toString();
    final status = (raw["status"] ?? (raw["isRead"] == true ? "seen" : "sent")).toString();
    m["status"] = status;
    m["isRead"] = raw["isRead"] == true || status == "seen";
    m["createdAt"] = raw["createdAt"];
    _messages.add(m);
  }

  Future<void> connectSocket(String meId) async {
    _meId = meId;
    if (socket != null) return;

    socket = IO.io(
      ApiConstants.socketBaseUrl, // <- NO /api for socket
      {"transports": ["websocket"], "autoConnect": true},
    );

    socket!.onConnect((_) => socket!.emit("join", meId));

    socket!.on("receiveMessage", (raw) {
      // append regardless; UI shows only current convo
      _normalizeAndAppend(raw);
      notifyListeners();
    });

    socket!.on("messageStatus", (data) {
      final id = (data["messageId"] ?? "").toString();
      final status = (data["status"] ?? "").toString();
      final idx = _messages.indexWhere((e) => e["_id"] == id);
      if (idx != -1) {
        _messages[idx]["status"] = status;
        _messages[idx]["isRead"] = status == "seen" ? true : _messages[idx]["isRead"] == true;
        notifyListeners();
      }
    });

    socket!.on("messagesSeen", (data) {
      final by = (data["by"] ?? "").toString();
      final List ids = (data["ids"] as List?) ?? [];
      if (by == _peerId) {
        for (final mid in ids) {
          final i = _messages.indexWhere((e) => e["_id"] == mid.toString());
          if (i != -1) {
            _messages[i]["status"] = "seen";
            _messages[i]["isRead"] = true;
          }
        }
        notifyListeners();
      }
    });

    socket!.on("typing", (payload) {
      final senderId = (payload?["senderId"] ?? "").toString();
      _isTypingFromPeer = (senderId == _peerId);
      notifyListeners();
    });

    socket!.on("stopTyping", (payload) {
      final senderId = (payload?["senderId"] ?? "").toString();
      if (senderId == _peerId) {
        _isTypingFromPeer = false;
        notifyListeners();
      }
    });

    socket!.onDisconnect((_) {
      _isTypingFromPeer = false;
      notifyListeners();
    });
  }

  void setPeer(String peerId, {String? token}) {
    _peerId = peerId;
    _token = token ?? _token;
  }

  Future<void> fetchChat(String token, String meId, String peerId) async {
    _token = token;
    _meId = meId;
    _peerId = peerId;
    _messages.clear();

    final r = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/chat/$peerId"), // <- WITH /api in baseUrl
      headers: {"Authorization": "Bearer $token"},
    );
    final List list = json.decode(r.body) as List;
    for (final raw in list) _normalizeAndAppend(raw);
    notifyListeners();

    // mark read
    await http.put(
      Uri.parse("${ApiConstants.baseUrl}/chat/read/$peerId"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty || socket == null || _meId == null || _peerId == null) return;
    socket!.emit("sendMessage", {
      "senderId": _meId,
      "receiverId": _peerId,
      "message": text.trim(),
    });
    // Server will echo; no optimistic insert necessary.
  }

  void sendTyping() {
    if (socket == null || _meId == null || _peerId == null) return;
    socket!.emit("typing", {"senderId": _meId, "receiverId": _peerId});
  }

  void stopTyping() {
    if (socket == null || _meId == null || _peerId == null) return;
    socket!.emit("stopTyping", {"senderId": _meId, "receiverId": _peerId});
  }
}
