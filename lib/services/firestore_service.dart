import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/announcement_model.dart';
import '../models/module_model.dart';
import '../models/time_slot_model.dart';

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
}
