import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../address/address_screen.dart';
import '../../authentication/login_screen.dart';
import '../../authentication/terms_screen.dart';
import '../../information/faq_screen.dart';
import '../../information/privacy_screen.dart';
import '../../messages/chat_screen.dart';
import '../../orders/orders_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Widget buildMenuButton(String title, VoidCallback onTap) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            'User Profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Menu Buttons
          buildMenuButton('My Orders', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            );
          }),
          buildMenuButton('My Addresses', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressScreen()),
            );
          }),
          
          buildMenuButton('Chat with Us', () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ChatScreen(adminId: "68ff619c695579918643a100")),
  );
}),

buildMenuButton('Terms & Conditions', () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const TermsScreen()),
  );
}),

buildMenuButton('Privacy Policy', () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PrivacyScreen()),
  );
}),

buildMenuButton('FAQs', () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const FAQScreen()),
  );
}),




          buildMenuButton('Logout', () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Logout'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true) {
              await authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            }
          }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
