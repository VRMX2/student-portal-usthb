import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/firestore_service.dart';
import '../models/module_model.dart';
import 'package:go_router/go_router.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  // Placeholder data
  final List<Module> _modules = [
    Module(id: '1', name: 'Algorithmique', code: 'INF101', coefficient: 4, gradeExam: 14, gradeTD: 15),
    Module(id: '2', name: 'Analyse 1', code: 'MATH101', coefficient: 3, gradeExam: 10, gradeTD: 12),
    Module(id: '3', name: 'Physique 1', code: 'PHYS101', coefficient: 3, gradeTP: 16),
  ];

  double get _semesterAverage {
    double totalPoints = 0;
    double totalCoeff = 0;
    for (var m in _modules) {
      totalPoints += m.average * m.coefficient;
      totalCoeff += m.coefficient;
    }
    return totalCoeff == 0 ? 0.0 : totalPoints / totalCoeff;
  }

  void _addOrEditModule({Module? module}) {
    // Show dialog to add or edit
    // Only UI demo for now
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(module == null ? 'Add Module' : 'Edit Module'),
        content: const Text('Module editing form goes here'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Modules')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditModule(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // GPA Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black.withAlpha(25), // 0.1 opacity
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Semester Average',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _semesterAverage.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Coefficients: ${_modules.fold(0.0, (sum, m) => sum + m.coefficient).toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          // Module List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _modules.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final module = _modules[index];
                final avg = module.average;
                final isPassing = avg >= 10;

                return Card(
                  child: ListTile(
                    onTap: () => _addOrEditModule(module: module),
                    leading: CircleAvatar(
                      backgroundColor: isPassing ? Colors.green.shade100 : Colors.red.shade100,
                      child: Text(
                        module.coefficient.toStringAsFixed(0),
                        style: TextStyle(
                            color: isPassing ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(module.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Avg: ${avg.toStringAsFixed(2)} / 20'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
