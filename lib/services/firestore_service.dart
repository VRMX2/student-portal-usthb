import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/announcement_model.dart';
import '../models/module_model.dart';
import '../models/time_slot_model.dart';
import '../models/resource_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Student Methods
  Future<void> createStudent(Student student) async {
    await _db.collection('users').doc(student.id).set(student.toMap());
  }

  Future<Student?> getStudent(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return Student.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<Student>> getAllStudents() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateStudent(Student student) async {
    await _db.collection('users').doc(student.id).update(student.toMap());
  }

  // Announcement Methods
  Future<void> createAnnouncement(Announcement announcement) async {
    await _db.collection('announcements').doc(announcement.id).set(announcement.toMap());
  }

  Stream<List<Announcement>> getAnnouncements() {
    return _db.collection('announcements')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Announcement.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Module Methods
  Stream<List<Module>> getUserModules(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('modules')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Module.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addModule(String uid, Module module) async {
    // If id is empty or 'new', let Firestore generate one, but we passed it in object.
    // Better to use .add() if id is not set, or .doc(id).set() if we generated one locally.
    // For simplicity, we assume the UI might generate a UUID or we let Firestore do it.
    // Here we'll use .doc(module.id).set(...)
    await _db
        .collection('users')
        .doc(uid)
        .collection('modules')
        .doc(module.id)
        .set(module.toMap());
  }

  Future<void> updateModule(String uid, Module module) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('modules')
        .doc(module.id)
        .update(module.toMap());
  }

  Future<void> deleteModule(String uid, String moduleId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('modules')
        .doc(moduleId)
        .delete();
  }

  // Schedule Methods
  Stream<List<TimeSlot>> getSchedule(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('schedule')
        .snapshots()
        .map((snapshot) {
          final slots = snapshot.docs.map((doc) => _timeSlotFromMap(doc.data(), doc.id)).toList();
          return slots;
        });
  }

  Future<void> addTimeSlot(String uid, TimeSlot slot) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('schedule')
        .doc(slot.id)
        .set(slot.toMap());
  }

  Future<void> deleteTimeSlot(String uid, String slotId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('schedule')
        .doc(slotId)
        .delete();
  }
  
  // Helper to parse TimeOfDay from string "HH:MM"
  TimeSlot _timeSlotFromMap(Map<String, dynamic> data, String id) {
    final startParts = (data['startTime'] as String).split(':');
    final endParts = (data['endTime'] as String).split(':');

    return TimeSlot(
      id: id,
      subjectName: data['subjectName'] ?? '',
      type: data['type'] ?? '',
      location: data['location'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? '',
      startTime: TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1])),
      endTime: TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1])),
      professorName: data['professorName'] ?? '',
    );
  }

  // Resource Methods
  Stream<List<Resource>> getResources(String? moduleName) {
    Query query = _db.collection('resources').orderBy('uploadDate', descending: true);
    if (moduleName != null && moduleName != 'All') {
      query = query.where('moduleId', isEqualTo: moduleName);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Resource.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addResource(Resource resource) async {
    await _db.collection('resources').doc(resource.id).set(resource.toMap());
  }
}
