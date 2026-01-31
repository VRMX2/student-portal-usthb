import 'package:flutter/material.dart';

class TimeSlot {
  final String id;
  final String subjectName;
  final String type; // Course, TD, TP
  final String location; // Room 101, Amphi A
  final String dayOfWeek; // Monday, Tuesday...
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String professorName;

  TimeSlot({
    required this.id,
    required this.subjectName,
    required this.type,
    required this.location,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.professorName,
  });

  // Helper to convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'type': type,
      'location': location,
      'dayOfWeek': dayOfWeek,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'professorName': professorName,
    };
  }
}
