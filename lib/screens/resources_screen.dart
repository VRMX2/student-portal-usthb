import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // Uncomment when dependency is active
import '../models/resource_model.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  // Mock Data
  final List<String> _modules = ['Algorithmique', 'Analyse 1', 'Physique 1', 'Chimie 1'];
  String? _selectedModule;

  final List<Resource> _allResources = [
    Resource(id: '1', title: 'Cours 1: Introduction', moduleId: 'Algorithmique', url: '#', type: ResourceType.pdf, uploadDate: DateTime.now(), size: '1.2 MB'),
    Resource(id: '2', title: 'Serie TD 1', moduleId: 'Algorithmique', url: '#', type: ResourceType.pdf, uploadDate: DateTime.now(), size: '0.5 MB'),
    Resource(id: '3', title: 'Correction Exam 2024', moduleId: 'Analyse 1', url: '#', type: ResourceType.pdf, uploadDate: DateTime.now(), size: '2.1 MB'),
  ];

  @override
  Widget build(BuildContext context) {
    List<Resource> displayedResources = _selectedModule == null 
        ? _allResources 
        : _allResources.where((r) => r.moduleId == _selectedModule).toList();

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
              itemCount: _modules.length + 1,
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final moduleName = isAll ? 'All' : _modules[index - 1];
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayedResources.length,
              itemBuilder: (context, index) {
                final resource = displayedResources[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(resource.title),
                    subtitle: Text('${resource.moduleId} • ${resource.size}'),
                    trailing: const Icon(Icons.download_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Downloading...')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Upload logic for admin/delegates
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
