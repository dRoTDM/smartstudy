import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  final String email;

  const ProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final username = email; // Username = email

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                child:
                    const Icon(Icons.person, size: 40, color: Colors.white70),
              ),
              const SizedBox(height: 20),

              Text("$email",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

          

              const SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14)),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  },
                  child: const Text("Logout",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ]),
      ),
      bottomNavigationBar: buildBottomNav(context, 2, email),
    );
  }
}
