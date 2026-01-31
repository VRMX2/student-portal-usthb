import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/announcement_model.dart';

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

  // Placeholder for Module Methods
  Stream<QuerySnapshot> getModules() {
    return _db.collection('modules').snapshots();
  }
}
