import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NotificationProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: np.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: np.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final n = np.items[i];
                return ListTile(
                  title: Text(n.title, style: TextStyle(
                    fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600)),
                  subtitle: Text(n.message),
                  trailing: n.isRead ? null : const Icon(Icons.circle, size: 10, color: Colors.blue),
                  onTap: () {
                    if (auth.token != null) {
                      np.markRead(n.id, auth.token!);
                    }
                  },
                );
              },
            ),
    );
  }
}
