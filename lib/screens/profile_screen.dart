import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart'; // Will use if we have UserProvider
// import '../services/auth_service.dart';
// import '../models/student_model.dart';
// import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Placeholder for fetching user data
  bool _isLoading = true;
  // Student? _student;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    // Simulate fetch
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Student Name',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Matricule: 123456789',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(context),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Navigate to edit profile
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
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
            _buildListTile(Icons.school, 'Faculty', 'Informatique'),
            const Divider(),
            _buildListTile(Icons.timeline, 'Level', 'L3'),
            const Divider(),
            _buildListTile(Icons.class_, 'Department', 'Software Engineering'),
            const Divider(),
            _buildListTile(Icons.email, 'Email', 'student@usthb.dz'),
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
