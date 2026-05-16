import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class CustomAnimatedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomAnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar(
      icons: const [
        Icons.home_outlined,
        Icons.search,
        Icons.person_outline,
      ],

      activeIndex: currentIndex,
      gapLocation: GapLocation.none,

      backgroundColor: Colors.black,
      activeColor: Colors.white,
      inactiveColor: Colors.white54,

      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 18,
      rightCornerRadius: 18,

      iconSize: 28,
      height: 60,
      elevation: 5,

      onTap: onTap,
    );
  }
}
