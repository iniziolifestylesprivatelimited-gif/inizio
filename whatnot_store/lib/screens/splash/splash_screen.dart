import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../providers/app_lock_provider.dart';
import '../../providers/auth_provider.dart';
import '../authentication/login_screen.dart';
import '../homescreen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset("assets/logos/inizio.png")
      ..initialize().then((_) {
        _controller.setVolume(0);
        _controller.play();
        setState(() {});
      });

       // NEW: run biometric immediately when splash loads
 WidgetsBinding.instance.addPostFrameCallback((_) async {
final appLock =
    Provider.of<AppLockProvider>(
  context,
  listen: false,
);

while (!appLock.isLoaded) {
  await Future.delayed(
    const Duration(milliseconds: 100),
  );
}

/// SPLASH WAIT
await Future.delayed(
  const Duration(seconds: 2),
);

if (appLock.isAppLockEnabled) {

  bool success = await _authenticate();

  if (success) {
    _goNext();
  }

} else {

  await _showEnableLockPopup();

}
});



  
  }

void _goNext() async {
  final auth = Provider.of<AuthProvider>(context, listen: false);

  if (auth.token != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }
}

Future<void> _showUnlockScreen() async {

  bool success = await _authenticate();

  if (!success) {
    return;
  }

  _goNext();
}

Future<bool> _authenticate() async {

  final LocalAuthentication auth =
      LocalAuthentication();

  try {

    /// CHECK AVAILABLE BIOMETRICS
    final bool canAuthenticate =
        await auth.canCheckBiometrics ||
        await auth.isDeviceSupported();

    if (!canAuthenticate) {
      return false;
    }

    /// OPTIONAL:
    /// GET AVAILABLE TYPES
    final availableBiometrics =
        await auth.getAvailableBiometrics();

    debugPrint(
      "Available Biometrics: $availableBiometrics",
    );

    /// FACE ID + FINGERPRINT + PASSCODE
    final bool didAuthenticate =
        await auth.authenticate(

      localizedReason:
          "Unlock Inizio securely",

      options: const AuthenticationOptions(

        /// IMPORTANT
        biometricOnly: false,

        /// KEEP SESSION
        stickyAuth: true,

        /// SHOW SYSTEM DIALOGS
        useErrorDialogs: true,
      ),
    );

    return didAuthenticate;

  } catch (e) {

    debugPrint(
      "Biometric Error: $e",
    );

    return false;
  }
}

Future<void> _showEnableLockPopup() async {

  final appLock =
      Provider.of<AppLockProvider>(
    context,
    listen: false,
  );

  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,

    builder: (_) {

      return Container(
        padding: const EdgeInsets.all(24),

        decoration: const BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),

        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// TOP INDICATOR
              Container(
                width: 60,
                height: 5,

                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 30),

              /// ICON
              Container(
                width: 90,
                height: 90,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade50,
                ),

                child: Icon(
                  Icons.fingerprint_rounded,
                  size: 55,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 28),

              /// TITLE
              const Text(
                "Secure Your App",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              /// SUBTITLE
              Text(
                "Use fingerprint or device screen lock to protect your account and orders securely.",
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 35),

              /// ENABLE BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton.icon(

                  icon: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                  ),

                  label: const Text(
                    "Enable Security",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),

                  onPressed: () async {

                    await appLock.toggleAppLock(true);

                    Navigator.pop(context);

                    bool success =
    await _authenticate();

if (success) {

  _goNext();

} else {

  await appLock.toggleAppLock(false);
}
                  },
                ),
              ),

              const SizedBox(height: 14),

              /// MAYBE LATER
              TextButton(
                onPressed: () {

  Navigator.pop(context);

  _goNext();
},

                child: const Text(
                  "Maybe Later",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}




  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
