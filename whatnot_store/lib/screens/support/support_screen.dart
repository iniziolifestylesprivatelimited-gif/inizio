import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../messages/chat_screen.dart';
import '../information/faq_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const String supportNumber = "+919281107553";
  static const String supportEmail = "contactus@whatnot.in";
  static const String adminId = "68ff619c695579918643a100";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Support", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _supportTile(
              icon: Icons.chat_bubble_outline,
              title: "Chat with Support",
              subtitle: "Get instant help via chat",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatScreen(adminId: adminId),
                  ),
                );
              },
            ),
            _supportTile(
              icon: Icons.call_outlined,
              title: "Call Us",
              subtitle: supportNumber,
              onTap: () => _callSupport(),
            ),
            _supportTile(
              icon: Icons.email_outlined,
              title: "Email Us",
              subtitle: supportEmail,
              onTap: () => _emailSupport(),
            ),
            _supportTile(
              icon: Icons.help_outline,
              title: "FAQs",
              subtitle: "Common questions & answers",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FAQScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------- HELPERS ----------

  static Widget _supportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 28, color: Colors.black),
        title: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  static Future<void> _callSupport() async {
    final uri = Uri.parse("tel:$supportNumber");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> _emailSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: 'subject=Support Request',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
