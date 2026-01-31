import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/resource_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  // We will fetch unique module names from the user's enrolled modules to filter resources
  // Or just hardcode common ones / fetch from a 'subjects' collection if we had one.
  // For now, we'll use a hardcoded list of common USTHB first year modules + allow 'All'
  final List<String> _subjects = ['Algorithmique', 'Analyse 1', 'Physique 1', 'Chimie 1', 'Terminologie', 'Anglais'];
  String? _selectedModule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: Column(
        children: [
          // Module Filter
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: _subjects.length + 1,
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final moduleName = isAll ? 'All' : _subjects[index - 1];
                final isSelected = isAll ? _selectedModule == null : _selectedModule == moduleName;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(moduleName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                         _selectedModule = isAll ? null : moduleName;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<Resource>>(
              stream: FirestoreService().getResources(_selectedModule),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final displayedResources = snapshot.data ?? [];

                if (displayedResources.isEmpty) {
                  return const Center(child: Text('No resources found for this subject.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayedResources.length,
                  itemBuilder: (context, index) {
                    final resource = displayedResources[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          resource.type == ResourceType.pdf ? Icons.picture_as_pdf : Icons.image, 
                          color: resource.type == ResourceType.pdf ? Colors.red : Colors.blue
                        ),
                        title: Text(resource.title),
                        subtitle: Text('${resource.moduleId} • ${resource.size}'),
                        trailing: const Icon(Icons.download_rounded),
                        onTap: () {
                          // In a real app, use url_launcher or dio to download
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Opening ${resource.title}...')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder for upload - in a real app this would pick file & upload to storage
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload feature would open File Picker here.')),
          );
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
