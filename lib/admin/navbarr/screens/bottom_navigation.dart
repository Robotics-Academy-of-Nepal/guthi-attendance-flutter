import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ACustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ACustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withAlpha(25),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: GNav(
          gap: 8,
          activeColor: Colors.blue,
          color: const Color.fromARGB(255, 93, 89, 89),
          tabBackgroundColor: Colors.blue.withAlpha(128),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          tabs: const [
            GButton(
              icon: Icons.event,
              text: 'Leave',
            ),
            GButton(
              icon: Icons.fact_check,
              text: 'Logs',
            ),
            GButton(
              icon: Icons.person,
              text: 'Profile',
            )
          ],
          selectedIndex: currentIndex,
          onTabChange: onTap,
        ),
      ),
    );
  }
}
