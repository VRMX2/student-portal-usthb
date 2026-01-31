import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/module_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AcademicHistoryScreen extends StatefulWidget {
  const AcademicHistoryScreen({super.key});

  @override
  State<AcademicHistoryScreen> createState() => _AcademicHistoryScreenState();
}

class _AcademicHistoryScreenState extends State<AcademicHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final uid = authService.user?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Academic History')),
      body: StreamBuilder<List<Module>>(
        stream: FirestoreService().getUserModules(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final modules = snapshot.data ?? [];
          if (modules.isEmpty) {
            return const Center(child: Text('No academic records found.'));
          }

          // Group by Year and Semester
          // Map<String, Map<String, List<Module>>>
          // Year -> Semester -> Modules
          final Map<String, Map<String, List<Module>>> history = {};

          for (var module in modules) {
            history.putIfAbsent(module.year, () => {});
            history[module.year]!.putIfAbsent(module.semester, () => []);
            history[module.year]![module.semester]!.add(module);
          }

          // Sort years and semesters if needed (assuming strings behave nicely or use custom logic)
          // For simplicity, we just iterate keys.

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.keys.length,
            itemBuilder: (context, index) {
              final year = history.keys.elementAt(index);
              final semesters = history[year]!;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Year: $year',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      ...semesters.keys.map((semester) {
                        final semesterModules = semesters[semester]!;
                        final semesterAverage = _calculateAverage(semesterModules);

                        return ExpansionTile(
                          title: Text('$semester - Avg: ${semesterAverage.toStringAsFixed(2)}/20'),
                          children: semesterModules.map((module) {
                            return ListTile(
                              title: Text(module.name),
                              subtitle: Text('Coeff: ${module.coefficient}'),
                              trailing: Text(
                                '${module.average.toStringAsFixed(2)}/20',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: module.average >= 10 ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  double _calculateAverage(List<Module> modules) {
    if (modules.isEmpty) return 0.0;
    double totalPoints = 0;
    double totalCoefficients = 0;

    for (var module in modules) {
      totalPoints += module.average * module.coefficient;
      totalCoefficients += module.coefficient;
    }

    if (totalCoefficients == 0) return 0.0;
    return totalPoints / totalCoefficients;
  }
}
