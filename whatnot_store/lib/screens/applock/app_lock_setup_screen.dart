import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_lock_provider.dart';
import '../homescreen/home_screen.dart';

class AppLockSetupScreen extends StatelessWidget {
  const AppLockSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLock = Provider.of<AppLockProvider>(context);

    if (appLock.isAppLockEnabled) {
      // already enabled → go directly to home (Splash shows biometrics)
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      });
    }

    return AlertDialog(
      title: const Text("Enable App Lock"),
      content: const Text("Protect your app using fingerprint or screen lock for better security."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            await appLock.toggleAppLock(true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
          child: const Text("Enable"),
        ),
      ],
    );
  }
}
