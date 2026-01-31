import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAdminCard(
            context,
            'Manage Announcements',
            Icons.campaign,
            Colors.orange,
            () {
              context.push('/admin/create-announcement');
            },
          ),
          _buildAdminCard(
            context,
            'Manage Users',
            Icons.people,
            Colors.blue,
            () {
              context.push('/admin/user-management');
            },
          ),
          _buildAdminCard(
            context,
            'Manage Modules',
            Icons.library_books,
            Colors.green,
            () {
              // Navigate to Module Manager
            },
          ),
           _buildAdminCard(
            context,
            'Upload Resources',
            Icons.upload_file,
            Colors.purple,
            () {
              // Navigate to Upload
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 30,
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
