import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/user_type.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/app_navigation.dart';

class WorkoutCreator extends StatefulWidget {
  const WorkoutCreator({super.key});

  @override
  State<WorkoutCreator> createState() => _WorkoutCreatorState();
}

class _WorkoutCreatorState extends State<WorkoutCreator> {
  final _formKey = GlobalKey<FormState>();
  final _workoutNameController = TextEditingController();
  final _exerciseNameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  List<Map<String, dynamic>> exercises = [];
  String _selectedDifficulty = 'Intermediate';
  String _selectedFocus = 'Full Body';
  String _selectedClient = 'All Clients';

  @override
  void dispose() {
    _workoutNameController.dispose();
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Workout Creator',
      userType: UserType.trainer,
      selectedNavIndex: 2,
      onNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/trainer/client-list');
            break;
          case 1:
            Navigator.pushNamed(context, '/trainer/ai-reports');
            break;
          case 3:
            Navigator.pushNamed(context, '/messages');
            break;
          case 4:
            Navigator.pushNamed(
              context,
              '/profile',
              arguments: UserType.trainer,
            );
            break;
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWorkoutDetails(),
              const SizedBox(height: 24),
              _buildExerciseList(),
              const SizedBox(height: 24),
              _buildAddExercise(),
              const SizedBox(height: 24),
              _buildAssignWorkout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _workoutNameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                hintText: 'Enter workout name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a workout name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Beginner', 'Intermediate', 'Advanced']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedDifficulty = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFocus,
                    decoration: const InputDecoration(
                      labelText: 'Focus Area',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Full Body',
                      'Upper Body',
                      'Lower Body',
                      'Core',
                      'Cardio'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedFocus = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercises',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (exercises.isEmpty)
              const Center(
                child: Text('No exercises added yet'),
              )
            else
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  return Card(
                    key: ValueKey(index),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Text('${index + 1}'),
                      title: Text(exercise['name']),
                      subtitle: Text(
                        '${exercise['sets']} sets x ${exercise['reps']} reps @ ${exercise['weight']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editExercise(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeExercise(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = exercises.removeAt(oldIndex);
                    exercises.insert(newIndex, item);
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddExercise() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Exercise',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _exerciseNameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                hintText: 'Enter exercise name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setsController,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _repsController,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight/Resistance',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any additional notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignWorkout() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign Workout',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedClient,
              decoration: const InputDecoration(
                labelText: 'Select Client',
                border: OutlineInputBorder(),
              ),
              items: ['All Clients', 'John Smith', 'Sarah Johnson']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedClient = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement save as template
                    },
                    child: const Text('Save as Template'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _assignWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('Assign Workout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addExercise() {
    if (_exerciseNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an exercise name')),
      );
      return;
    }

    setState(() {
      exercises.add({
        'name': _exerciseNameController.text,
        'sets': _setsController.text,
        'reps': _repsController.text,
        'weight': _weightController.text,
        'notes': _notesController.text,
      });

      _exerciseNameController.clear();
      _setsController.clear();
      _repsController.clear();
      _weightController.clear();
      _notesController.clear();
    });
  }

  void _editExercise(int index) {
    final exercise = exercises[index];
    _exerciseNameController.text = exercise['name'];
    _setsController.text = exercise['sets'];
    _repsController.text = exercise['reps'];
    _weightController.text = exercise['weight'];
    _notesController.text = exercise['notes'];

    setState(() {
      exercises.removeAt(index);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
  }

  void _assignWorkout() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    // TODO: Implement workout assignment logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout assigned successfully')),
    );
  }
} 