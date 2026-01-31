import 'package:flutter/material.dart';
import '../models/time_slot_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];

  // Mock Data
  final Map<String, List<TimeSlot>> _schedule = {
    'Sun': [
      TimeSlot(
        id: '1', 
        subjectName: 'Algorithmique', 
        type: 'Course', 
        location: 'Amphi D', 
        dayOfWeek: 'Sun', 
        startTime: const TimeOfDay(hour: 8, minute: 0), 
        endTime: const TimeOfDay(hour: 9, minute: 30), 
        professorName: 'Dr. Boukerram'
      ),
      TimeSlot(
        id: '2', 
        subjectName: 'Algorithmique', 
        type: 'TD', 
        location: 'Salle 224', 
        dayOfWeek: 'Sun', 
        startTime: const TimeOfDay(hour: 9, minute: 40), 
        endTime: const TimeOfDay(hour: 11, minute: 10), 
        professorName: 'Mme. Amrouche'
      ),
    ],
    'Mon': [
       TimeSlot(
        id: '3', 
        subjectName: 'Analyse 1', 
        type: 'Course', 
        location: 'Amphi E', 
        dayOfWeek: 'Mon', 
        startTime: const TimeOfDay(hour: 11, minute: 20), 
        endTime: const TimeOfDay(hour: 12, minute: 50), 
        professorName: 'Pr. Khelladi'
      ),
    ],
    'Tue': [],
    'Wed': [],
    'Thu': [],
  };

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days.map((day) {
          final slots = _schedule[day] ?? [];
          if (slots.isEmpty) {
            return const Center(child: Text('No classes today!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              return _buildTimeSlotCard(slots[index]);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot) {
    Color typeColor = Colors.blue;
    if (slot.type == 'TD') typeColor = Colors.orange;
    if (slot.type == 'TP') typeColor = Colors.green;

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
                  Text(
                    slot.subjectName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
