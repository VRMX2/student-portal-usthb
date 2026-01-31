import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State
  Student? _student;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final authService = context.read<AuthService>();
    final uid = authService.user?.uid;
    if (uid != null) {
      final student = await FirestoreService().getStudent(uid);
      if (mounted) {
        setState(() {
          _student = student;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_student == null) {
       return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              backgroundImage: _student!.profilePhotoUrl != null ? NetworkImage(_student!.profilePhotoUrl!) : null,
              child: _student!.profilePhotoUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
            ),
            const SizedBox(height: 16),
            Text(
              _student!.fullName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              'Matricule: ${_student!.matricule}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(context),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                 await context.push('/edit-profile', extra: _student);
                 _fetchProfile(); // Refresh on return
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/academic-history'),
              icon: const Icon(Icons.history_edu),
              label: const Text('Academic History'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
             TextButton.icon(
              onPressed: () {
                context.push('/admin');
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Admin Access (Demo)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildListTile(Icons.school, 'Faculty', _student!.faculty),
            const Divider(),
            _buildListTile(Icons.timeline, 'Level', _student!.academicLevel),
            const Divider(),
            _buildListTile(Icons.class_, 'Department', _student!.department),
            const Divider(),
            _buildListTile(Icons.email, 'Email', _student!.email),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }
}
