import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav.dart';
import 'profile_screen.dart';
import 'placeholder_screen.dart';

const Color bg = Color(0xFFF5F6F8);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? email;
  String username = "Student";
  List<Map<String, dynamic>> tasks = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map && args['email'] != null) {
      email = args['email'] as String;
      username = _extractName(email!);
      setState(() {});
    }

    _loadTasks();
  }

  String _extractName(String email) {
    final namePart = email.split('@').first;
    if (namePart.isNotEmpty) {
      return namePart[0].toUpperCase() + namePart.substring(1);
    }
    return "Student";
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTasks = prefs.getString('tasks');

    if (storedTasks != null) {
      final decoded = jsonDecode(storedTasks) as List;

      setState(() {
        tasks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        tasks.sort((a, b) {
          try {
            return DateTime.parse(a['date']).compareTo(DateTime.parse(b['date']));
          } catch (_) {
            return 0;
          }
        });
      });
    }
  }

  Map<String, dynamic>? _nextTask() {
    if (tasks.isEmpty) return null;

    final now = DateTime.now();
    for (final t in tasks) {
      try {
        final dt = DateTime.parse(t['date']);
        if (dt.isAfter(now)) return t;
      } catch (_) {}
    }

    return tasks.first;
  }

  @override
  Widget build(BuildContext context) {
    final nextTask = _nextTask();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCourses(),
              const SizedBox(height: 22),
              const Text("Your Schedule",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              nextTask != null
                  ? _buildScheduleCard(nextTask)
                  : _buildEmptyScheduleCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNav(context, 0, email),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello $username",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              const SizedBox(height: 6),
              Text(
                "You've got\n${tasks.length} tasks today",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.green[700]),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white70),
        )
      ],
    );
  }

  Widget _buildCourses() {
    final courses = [
      {'title': 'Mathematics', 'color': const Color(0xFFDDE6FF)},
      {'title': 'Chemistry', 'color': const Color(0xFFFFE5D9)},
      {'title': 'Physics', 'color': const Color(0xFFFFD9EC)},
      {'title': 'Biology', 'color': const Color(0xFFD8FFF4)},
      {'title': 'History', 'color': const Color(0xFFFFF4CC)},
      {'title': 'English', 'color': const Color(0xFFE6F2FF)},
      {'title': 'Computer Science', 'color': const Color(0xFFE3FFE9)},
      {'title': 'Economics', 'color': const Color(0xFFFFE8F2)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Courses",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final Color cardColor = courses[i]['color'] as Color;
              final String title = courses[i]['title'] as String;

              return Container(
                width: 150,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> t) {
    final String title = t['title']?.toString() ?? "Task";
    final String subtitle = t['subtitle']?.toString() ?? "";

    DateTime dt;
    try {
      dt = DateTime.parse(t['date']);
    } catch (_) {
      dt = DateTime.now();
    }

    final String time =
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.indigo.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white),
              const SizedBox(width: 6),
              Text(time, style: const TextStyle(color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6))
          ]),
      child: Row(
        children: [
          const Expanded(
            child: Text("No tasks scheduled",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PlaceholderScreen()),
              );
            },
            child: const Text("Add Task"),
          )
        ],
      ),
    );
  }
}
