import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../address/address_screen.dart';
import '../../authentication/login_screen.dart';
import '../../authentication/terms_screen.dart';
import '../../information/faq_screen.dart';
import '../../information/privacy_screen.dart';
import '../../ledgers/ledger_screen.dart';
import '../../messages/chat_screen.dart';
import '../../orders/orders_screen.dart';
import '../../settiings/app_lock_settings_screen.dart';
import '../../support/support_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Widget buildMenuButton(String title, VoidCallback onTap) {
      return Card(
        color: Colors.white,
        shadowColor: Colors.black12,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 10,
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.black,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // const SizedBox(height: 50),

            // const CircleAvatar(
            //   radius: 50,
            //   backgroundColor: Colors.black,
            //   child: Icon(Icons.person, size: 50, color: Colors.white),
            // ),

            // const SizedBox(height: 16),

            // const Text(
            //   'User Profile',
            //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            // ),

            // const SizedBox(height: 30),

            // ------------------ MENU BUTTONS ------------------
            buildMenuButton('My Orders', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            }),

            buildMenuButton('My Ledgers', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LedgerScreen()),
              );
            }),

            buildMenuButton('My Addresses', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressScreen()),
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
            buildMenuButton('Support', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              );
            }),
            buildMenuButton('App Lock', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppLockSettingsScreen(),
                ),
              );
            }),

            buildMenuButton('Logout', () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => Theme(
                  data: Theme.of(context).copyWith(
                    dialogBackgroundColor: Colors.white,
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      surfaceTint: Colors.transparent,
                      surface: Colors.white,
                      surfaceVariant: Colors.white,
                    ),
                  ),
                  child: AlertDialog(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),

                    title: const Text(
                      'Confirm Logout',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    content: const Text(
                      'Are you sure you want to log out?',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),

                    actionsPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    actionsAlignment: MainAxisAlignment.spaceBetween,

                    actions: [
                      // CANCEL BUTTON (Grey)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // LOGOUT BUTTON (Black)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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
      ),
    );
  }
}
