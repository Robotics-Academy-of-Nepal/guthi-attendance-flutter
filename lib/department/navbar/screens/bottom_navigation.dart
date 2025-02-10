import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class DCustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DCustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, // Adjust horizontal padding
          vertical: screenHeight * 0.01, // Adjust vertical padding
        ),
        child: GNav(
          gap: screenWidth * 0.02, // Dynamic gap between items
          activeColor: Colors.blue,
          color: const Color.fromARGB(255, 93, 89, 89),
          tabBackgroundColor: Colors.blue.withAlpha(128),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // Dynamic tab padding
            vertical: screenHeight * 0.015,
          ),
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.event_busy_rounded,
              text: 'Leave',
            ),
            GButton(
              icon: Icons.event,
              text: 'Requests',
            ),
            GButton(
              icon: Icons.list,
              text: 'Activity',
            ),
            GButton(
              icon: Icons.person,
              text: 'Profile',
            ),
          ],
          selectedIndex: currentIndex,
          onTabChange: onTap,
        ),
      ),
    );
  }
}
