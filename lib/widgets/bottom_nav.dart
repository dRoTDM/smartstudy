import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/profile_screen.dart';

BottomNavigationBar buildBottomNav(
  BuildContext context,
  int currentIndex,
  String? email,
) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Tasks'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
    onTap: (index) {
      if (index == currentIndex) return;

      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PlaceholderScreen()),
        );
      } else if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(email: email ?? ''),
          ),
        );
      }
    },
  );
}
