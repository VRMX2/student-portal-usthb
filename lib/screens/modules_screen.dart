import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/module_model.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  // We no longer manage local state list manually, we derive it from stream
  
  double _calculateAverage(List<Module> modules) {
    double totalPoints = 0;
    double totalCoeff = 0;
    for (var m in modules) {
      totalPoints += m.average * m.coefficient;
      totalCoeff += m.coefficient;
    }
    return totalCoeff == 0 ? 0.0 : totalPoints / totalCoeff;
  }

  void _addOrEditModule(BuildContext context, String uid, {Module? module}) {
    final isEditing = module != null;
    final nameController = TextEditingController(text: module?.name ?? '');
    final codeController = TextEditingController(text: module?.code ?? '');
    final coeffController = TextEditingController(text: module?.coefficient.toString() ?? '1');
    final examController = TextEditingController(text: module?.gradeExam?.toString() ?? '');
    final tdController = TextEditingController(text: module?.gradeTD?.toString() ?? '');
    final tpController = TextEditingController(text: module?.gradeTP?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Module' : 'Add Module'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Algorithmique')),
              TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Code', hintText: 'e.g. INF101')),
              TextField(controller: coeffController, decoration: const InputDecoration(labelText: 'Coefficient'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              const Text('Grades (/20)'),
              Row(
                children: [
                   Expanded(child: TextField(controller: examController, decoration: const InputDecoration(labelText: 'Exam'), keyboardType: TextInputType.number)),
                   const SizedBox(width: 8),
                   Expanded(child: TextField(controller: tdController, decoration: const InputDecoration(labelText: 'TD'), keyboardType: TextInputType.number)),
                   const SizedBox(width: 8),
                   Expanded(child: TextField(controller: tpController, decoration: const InputDecoration(labelText: 'TP'), keyboardType: TextInputType.number)),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                final newModule = Module(
                  id: module?.id ?? const Uuid().v4(),
                  name: nameController.text.trim(),
                  code: codeController.text.trim(),
                  coefficient: double.tryParse(coeffController.text) ?? 1.0,
                  gradeExam: double.tryParse(examController.text),
                  gradeTD: double.tryParse(tdController.text),
                  gradeTP: double.tryParse(tpController.text),
                );

                if (isEditing) {
                  await FirestoreService().updateModule(uid, newModule);
                } else {
                  await FirestoreService().addModule(uid, newModule);
                }
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                // simple error handling
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteModule(BuildContext context, String uid, String moduleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module'),
        content: const Text('Are you sure you want to delete this module?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirestoreService().deleteModule(uid, moduleId);
              if (context.mounted) Navigator.pop(context);
            }, 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final uid = authService.user?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Modules')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditModule(context, uid),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Module>>(
        stream: FirestoreService().getUserModules(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final modules = snapshot.data ?? [];
          final semesterAverage = _calculateAverage(modules);
          final totalCoeff = modules.fold(0.0, (sum, m) => sum + m.coefficient);

          return Column(
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
                      color: Colors.black.withAlpha(25),
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
                      semesterAverage.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Coefficients: ${totalCoeff.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              // Module List
              Expanded(
                child: modules.isEmpty 
                  ? const Center(child: Text('No modules added yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: modules.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        final avg = module.average;
                        final isPassing = avg >= 10;

                        return Card(
                          child: ListTile(
                            onTap: () => _addOrEditModule(context, uid, module: module),
                            onLongPress: () => _deleteModule(context, uid, module.id),
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
                            trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                          ),
                        );
                      },
                    ),
              ),
            ],
          );
        }
      ),
    );
  }
}
