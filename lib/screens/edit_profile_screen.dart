import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Student student;

  const EditProfileScreen({super.key, required this.student});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _matriculeController;
  late TextEditingController _levelController;
  late TextEditingController _deptController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.fullName);
    _matriculeController = TextEditingController(text: widget.student.matricule);
    _levelController = TextEditingController(text: widget.student.academicLevel);
    _deptController = TextEditingController(text: widget.student.department);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _matriculeController.dispose();
    _levelController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final updatedStudent = Student(
        id: widget.student.id,
        email: widget.student.email, // Email is not editable here
        fullName: _nameController.text.trim(),
        matricule: _matriculeController.text.trim(),
        faculty: widget.student.faculty, // Faculty usually doesn't change easily
        academicLevel: _levelController.text.trim(),
        department: _deptController.text.trim(),
        profilePhotoUrl: widget.student.profilePhotoUrl,
        enrolledModuleIds: widget.student.enrolledModuleIds,
        metadata: widget.student.metadata,
      );

      await FirestoreService().updateStudent(updatedStudent);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
             TextField(
              controller: _matriculeController,
              decoration: const InputDecoration(labelText: 'Matricule', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
             TextField(
              controller: _levelController,
              decoration: const InputDecoration(labelText: 'Academic Level (e.g. L3)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
             TextField(
              controller: _deptController,
              decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isLoading ? null : _saveProfile,
              icon: const Icon(Icons.save),
              label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
