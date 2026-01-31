import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';
import '../models/student_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String matricule,
    required String faculty,
    required String academicLevel,
    required String department,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      
      // Create Student document
      final student = Student(
        id: credential.user!.uid,
        email: email,
        fullName: fullName,
        matricule: matricule,
        faculty: faculty,
        academicLevel: academicLevel,
        department: department,
      );

      try {
        await FirestoreService().createStudent(student);
      } catch (firestoreError) {
        // Rollback: If Firestore write fails, delete the Auth user
        // so the user can try registering again without "email already in use" error.
        await credential.user!.delete();
        throw Exception('Failed to create student profile. ${firestoreError.toString()}');
      }
      
      // If successful, signOut so they can login (optional, based on flow)
      // await signOut(); // Usually we want them signed in.
      
    } catch (e) {
      rethrow;
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        final studentDoc = await FirestoreService().getStudent(user.uid);
        if (studentDoc == null) {
          // Create a placeholder student record if it doesn't exist
          // The user will need to edit their profile to add matricule, faculty, etc.
          final newStudent = Student(
            id: user.uid,
            email: user.email ?? '',
            fullName: user.displayName ?? 'New Student',
            matricule: 'Update Me',
            faculty: 'Update Me',
            academicLevel: 'L1',
            department: 'Update Me',
          );
          await FirestoreService().createStudent(newStudent);
        }
      }

      return userCredential;
    } catch (e) {
      // Handle Google Sign-In errors specially if needed
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
