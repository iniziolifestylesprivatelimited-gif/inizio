import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';

class SocketService {
  static IO.Socket? socket;

  static void connect(String userId, void Function(Map<String, dynamic>) onNotification) {
    socket = IO.io(ApiConstants.baseUrl, {"transports": ["websocket"], "autoConnect": true});
    socket!.onConnect((_) => socket!.emit("join", userId));
    socket!.on("notification", (data) {
      if (data is Map) onNotification(Map<String, dynamic>.from(data));
    });
  }
}
