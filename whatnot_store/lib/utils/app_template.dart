import 'package:flutter/material.dart';

class AppTemplate extends StatelessWidget {
  final Widget child; // screen content
  final String? logoPath; // optional logo
  final double topSpace; // spacing before container

  const AppTemplate({
    super.key,
    required this.child,
    this.logoPath = "assets/logos/logos.png",
    this.topSpace = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 🔥 black background
      body: SafeArea(
        child: Stack(
          children: [
            // 🔥 White bottom container
            Positioned.fill(
              top: topSpace,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                  ),
                ),
                child: SingleChildScrollView(child: child),
              ),
            ),

            // 🔥 Logo on top
            if (logoPath != null)
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Image.asset(
                    logoPath!,
                    height: 90,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
