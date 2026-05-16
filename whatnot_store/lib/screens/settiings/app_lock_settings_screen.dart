import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_lock_provider.dart';

class AppLockSettingsScreen extends StatelessWidget {
  const AppLockSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("App Lock",
      style: TextStyle
      (color: Colors.white),),
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white)
      ),
      
      body: Consumer<AppLockProvider>(
        builder: (context, lockProvider, _) {
          return SwitchListTile(
            title: const Text("Enable App Lock"),
            subtitle: const Text("Require fingerprint / Face unlock to open app"),
            value: lockProvider.isAppLockEnabled,
            onChanged: (value) async {
  await lockProvider.toggleAppLock(value);
  if (value) {
    Navigator.pop(context); // close screen
  }
},

          );
        },
      ),
    );
  }
}
