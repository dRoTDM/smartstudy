import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav.dart';

class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({Key? key}) : super(key: key);

  @override
  _PlaceholderScreenState createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('tasks');

    if (stored != null) {
      final decoded = jsonDecode(stored) as List;

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

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks));
  }

  Future<void> _addTaskDialog() async {
    final TextEditingController titleCtrl = TextEditingController();
    DateTime? pickedDate;
    TimeOfDay? pickedTime;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(hintText: 'Task title')),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('Pick Date & Time'),
              onPressed: () async {
                final date = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                );
                if (date == null) return;

                final time = await showTimePicker(
                  context: ctx,
                  initialTime: TimeOfDay.now(),
                );
                if (time == null) return;

                pickedDate = date;
                pickedTime = time;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty ||
                  pickedDate == null ||
                  pickedTime == null) {
                Navigator.pop(ctx);
                return;
              }

              final dt = DateTime(
                pickedDate!.year,
                pickedDate!.month,
                pickedDate!.day,
                pickedTime!.hour,
                pickedTime!.minute,
              );

              final newTask = {
                'title': titleCtrl.text.trim(),
                'date': dt.toIso8601String(),
                'subtitle': '',
              };

              setState(() {
                tasks.add(newTask);
                tasks.sort((a, b) {
                  return DateTime.parse(a['date'])
                      .compareTo(DateTime.parse(b['date']));
                });
              });

              _saveTasks();
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return "${d.day} ${months[d.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDate(today),
                      style: TextStyle(
                          color: Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text("Today",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addTaskDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: tasks.isEmpty
            ? Center(
                child: Text("No tasks yet. Add one!",
                    style: TextStyle(color: Colors.grey[700])))
            : ListView.separated(
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, i) {
                  final t = tasks[i];
                  final title = t['title']?.toString() ?? "Task";
                  final subtitle = t['subtitle']?.toString() ?? "";

                  DateTime dt;
                  try {
                    dt = DateTime.parse(t['date']);
                  } catch (_) {
                    dt = DateTime.now();
                  }

                  final String time =
                      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

                  final pastel = [
                    const Color(0xFFB7C6FF),
                    const Color(0xFFCFF7E0),
                    const Color(0xFFFFD9E0),
                  ];

                  final bgColor = pastel[i % pastel.length];

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 60,
                          child: Text(time,
                              textAlign: TextAlign.right,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(subtitle,
                                    style: const TextStyle(
                                        color: Colors.black54)),
                              ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: buildBottomNav(context, 1, null),
    );
  }
}
