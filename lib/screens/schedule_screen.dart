import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/time_slot_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addTimeSlot(BuildContext context, String uid) {
    final subjectController = TextEditingController();
    final locationController = TextEditingController();
    final professorController = TextEditingController();
    String selectedType = 'Course';
    String selectedDay = _days[_tabController.index]; // Default to current tab
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 30);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Course', 'TD', 'TP', 'Exam'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => selectedDay = v!),
                ),
                const SizedBox(height: 8),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
                const SizedBox(height: 8),
                TextField(controller: professorController, decoration: const InputDecoration(labelText: 'Professor')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: startTime);
                        if (t != null) setState(() => startTime = t);
                      },
                      child: Text('Start: ${startTime.format(context)}'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: endTime);
                        if (t != null) setState(() => endTime = t);
                      },
                      child: Text('End: ${endTime.format(context)}'),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                try {
                  final slot = TimeSlot(
                    id: const Uuid().v4(),
                    subjectName: subjectController.text.trim(),
                    type: selectedType,
                    location: locationController.text.trim(),
                    dayOfWeek: selectedDay,
                    startTime: startTime,
                    endTime: endTime,
                    professorName: professorController.text.trim(),
                  );
                  await FirestoreService().addTimeSlot(uid, slot);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTimeSlot(BuildContext context, String uid, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Remove this class from schedule?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirestoreService().deleteTimeSlot(uid, id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final uid = authService.user?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTimeSlot(context, uid),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<TimeSlot>>(
        stream: FirestoreService().getSchedule(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final allSlots = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: _days.map((day) {
              final daySlots = allSlots.where((s) => s.dayOfWeek == day).toList();
              // Sort by start time
              daySlots.sort((a, b) {
                final aMin = a.startTime.hour * 60 + a.startTime.minute;
                final bMin = b.startTime.hour * 60 + b.startTime.minute;
                return aMin.compareTo(bMin);
              });

              if (daySlots.isEmpty) {
                return const Center(child: Text('No classes today!'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: daySlots.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () => _deleteTimeSlot(context, uid, daySlots[index].id),
                    child: _buildTimeSlotCard(daySlots[index]),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot) {
    Color typeColor = Colors.blue;
    if (slot.type == 'TD') typeColor = Colors.orange;
    if (slot.type == 'TP') typeColor = Colors.green;
    if (slot.type == 'Exam') typeColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${slot.endTime.hour.toString().padLeft(2, '0')}:${slot.endTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(width: 4, height: 50, color: typeColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        slot.subjectName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          slot.type,
                          style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(slot.location, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prof: ${slot.professorName}',
                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
