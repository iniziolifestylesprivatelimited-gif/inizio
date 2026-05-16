import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/app_lock_provider.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLocked = true;
  bool _isAuthenticating = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);

  WidgetsBinding.instance.addPostFrameCallback((_) async {
  final appLock = Provider.of<AppLockProvider>(context, listen: false);

  /// wait until loadLockSetting completes
  await Future.delayed(const Duration(milliseconds: 200));

  if (appLock.isAppLockEnabled) {
    setState(() => _isLocked = true);
    await _authenticate();
  } else {
    setState(() => _isLocked = false);
  }
});


  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
  );
}


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

 AppLifecycleState? _lastState;

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  final appLock = Provider.of<AppLockProvider>(context, listen: false);

  if (_lastState == AppLifecycleState.paused &&
      state == AppLifecycleState.resumed &&
      appLock.isAppLockEnabled) {

    setState(() => _isLocked = true);
    _authenticate();
  }

  _lastState = state;
}


 Future<void> _authenticate() async {
  setState(() => _isAuthenticating = true);

  try {
    bool canCheck = await _localAuth.canCheckBiometrics;
    bool supported = await _localAuth.isDeviceSupported();

    if (!canCheck || !supported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometric not available on this device")),
      );
      setState(() {
        _isLocked = false;
        _isAuthenticating = false;
      });
      return;
    }

    final didAuthenticate = await _localAuth.authenticate(
  localizedReason: "Use fingerprint to unlock app",
  options: const AuthenticationOptions(
    biometricOnly: false,
    stickyAuth: true,
    useErrorDialogs: true,
  ),
);


    if (didAuthenticate) {
      setState(() => _isLocked = false);
      _animationController.forward();
    }

  } catch (e) {
    debugPrint("Biometric error: $e");
  }

  setState(() => _isAuthenticating = false);
}


  @override
Widget build(BuildContext context) {
  if (!_isLocked) return widget.child;

  return Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isAuthenticating ? null : _authenticate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 90,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Touch the fingerprint sensor",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              _isAuthenticating ? "Waiting for authentication..." : "Tap to retry",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
