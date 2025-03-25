import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/user_type.dart';
import '../../core/theme.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/breadcrumb_navigation.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/form_check/form_check_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  int _selectedNavIndex = 1; // Workouts tab
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isListView = true; // Add view toggle state

  // Exercise state management
  final Map<String, Map<String, dynamic>> _exerciseStates = {};
  final Map<String, Timer?> _exerciseTimers = {};
  final Map<String, bool> _isExerciseResting = {};
  final Map<String, int> _remainingRestTimes = {};
  static const String _workoutProgressKey = 'workout_progress';
  bool _isWorkoutCompleted = false;
  bool _showCompletionView = false;

  // Sample workout data - In a real app, this would come from a backend
  final Map<String, dynamic> _todaysWorkout = {
    'id': 'w1',
    'title': 'Lower Body Power',
    'trainer': 'Alex Johnson',
    'duration': '75-90 min',
    'difficulty': 'Intermediate',
    'focus': 'Strength & Power',
    'exercises': 8,
    'calories': 650,
    'muscleGroups': ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
    'description': 'A high-intensity lower body workout focusing on building strength and power through compound movements and strategic supersets.',
    'warmup': {
      'duration': '12-15 min',
      'exercises': [
        'Dynamic Stretching',
        'Bodyweight Squats 3x10',
        'Walking Lunges 2x10/leg',
        'Leg Swings 2x12/leg'
      ]
    },
      'exercises': [
        {
        'name': 'Barbell Back Squats',
        'sets': 4,
        'reps': '6-8',
        'rest': '180 sec',
        'weights': ['135 lbs', '185 lbs', '225 lbs', '245 lbs'],
        'notes': 'Focus on maintaining a neutral spine and proper bracing. Drive through heels and keep chest up throughout the movement.',
        'isSuperset': false
      },
      {
        'name': 'Romanian Deadlifts',
        'sets': 4,
        'reps': '8-10',
        'rest': '150 sec',
        'weights': ['155 lbs', '175 lbs', '195 lbs', '205 lbs'],
        'notes': 'Keep slight bend in knees, focus on hip hinge. Feel stretch in hamstrings and maintain neutral spine.',
        'isSuperset': false
      },
      {
        'name': 'Leg Press',
        'sets': 3,
        'reps': '10-12',
        'rest': '90 sec',
        'weights': ['360 lbs', '400 lbs', '440 lbs'],
        'notes': 'Position feet shoulder-width apart. Lower until knees reach 90 degrees.',
        'isSuperset': true,
        'supersetGroup': 'A',
        'supersetOrder': 1
      },
      {
        'name': 'Walking Lunges',
        'sets': 3,
        'reps': '12/leg',
        'rest': '90 sec',
        'weights': ['25 lbs', '30 lbs', '35 lbs'],
        'notes': 'Keep torso upright, take full steps. Control the descent.',
        'isSuperset': true,
        'supersetGroup': 'A',
        'supersetOrder': 2
      },
      {
        'name': 'Bulgarian Split Squats',
        'sets': 3,
        'reps': '12/leg',
        'rest': '60 sec',
        'weights': ['30 lbs', '35 lbs', '40 lbs'],
        'notes': 'Keep front foot far enough forward. Control the movement and maintain balance.',
        'isSuperset': true,
        'supersetGroup': 'B',
        'supersetOrder': 1
      },
      {
        'name': 'Goblet Squats',
        'sets': 3,
        'reps': '15',
        'rest': '90 sec',
        'weights': ['50 lbs', '60 lbs', '70 lbs'],
        'notes': 'Keep elbows in, chest up. Squat between legs, not behind.',
        'isSuperset': true,
        'supersetGroup': 'B',
        'supersetOrder': 2
      },
      {
        'name': 'Seated Calf Raises',
        'sets': 4,
        'reps': '15-20',
        'rest': '45 sec',
        'weights': ['90 lbs', '100 lbs', '110 lbs', '120 lbs'],
        'notes': 'Full range of motion. Pause at bottom and top of movement.',
        'isSuperset': true,
        'supersetGroup': 'C',
        'supersetOrder': 1
      },
      {
        'name': 'Standing Calf Raises',
        'sets': 4,
        'reps': '15-20',
        'rest': '60 sec',
        'weights': ['120 lbs', '140 lbs', '160 lbs', '180 lbs'],
        'notes': 'Keep legs straight but not locked. Focus on full contraction.',
        'isSuperset': true,
        'supersetGroup': 'C',
        'supersetOrder': 2
      }
    ],
    'cooldown': {
      'duration': '10 min',
      'exercises': [
        'Static Stretching',
        'Foam Rolling',
        'Light Walking'
      ]
    }
  };

  @override
  void initState() {
    super.initState();
    _initializeExerciseStates();
    _loadSavedProgress();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Cancel all active timers
    for (final timer in _exerciseTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  Future<void> _loadSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProgress = prefs.getString(_workoutProgressKey);
      
      if (savedProgress != null) {
        final decodedProgress = json.decode(savedProgress) as Map<String, dynamic>;
        setState(() {
          _exerciseStates.clear();
          decodedProgress.forEach((key, value) {
            _exerciseStates[key] = Map<String, dynamic>.from(value);
          });
          // Initialize rest states for loaded exercises
          _exerciseStates.keys.forEach((exerciseId) {
            _isExerciseResting[exerciseId] = false;
            _remainingRestTimes[exerciseId] = 0;
          });
        });
      }
    } catch (e) {
      // If there's any error loading saved progress, ensure we have default states
      _initializeExerciseStates();
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = json.encode(_exerciseStates);
    await prefs.setString(_workoutProgressKey, progressJson);
  }

  void _initializeExerciseStates() {
    setState(() {
      _exerciseStates.clear();
      for (final exercise in _todaysWorkout['exercises']) {
        final exerciseId = exercise['name'] as String;
        _exerciseStates[exerciseId] = {
          ...exercise,
          'completed': 0,
          'currentWeight': exercise['weights'][0],
          'notes': exercise['notes'] ?? '',
        };
        _isExerciseResting[exerciseId] = false;
        _remainingRestTimes[exerciseId] = 0;
      }
    });
    _saveProgress();
  }

  void _startRestTimer(String exerciseId, int seconds) {
    // Cancel any existing timer first
    _exerciseTimers[exerciseId]?.cancel();
    
    setState(() {
      _isExerciseResting[exerciseId] = true;
      _remainingRestTimes[exerciseId] = seconds;
    });

    _exerciseTimers[exerciseId] = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingRestTimes[exerciseId]! > 0) {
        setState(() {
          _remainingRestTimes[exerciseId] = _remainingRestTimes[exerciseId]! - 1;
        });
        } else {
          timer.cancel();
        setState(() {
          _isExerciseResting[exerciseId] = false;
          _remainingRestTimes[exerciseId] = 0;
          
          // Complete the set only after rest is finished
          final exercise = _exerciseStates[exerciseId]!;
          final currentCompleted = exercise['completed'] as int;
          final totalSets = exercise['sets'] as int;
          
          if (currentCompleted < totalSets) {
            _exerciseStates[exerciseId]!['completed'] = currentCompleted + 1;
            _saveProgress();

            // Check if entire workout is completed
            bool allExercisesCompleted = _exerciseStates.values.every((exercise) {
              return exercise['completed'] >= exercise['sets'];
            });

            if (allExercisesCompleted) {
              _isWorkoutCompleted = true;
              _showCompletionView = true;
              _showWorkoutCompletionDialog();
            } else if (currentCompleted + 1 == totalSets) {
              _showExerciseCompletionMessage(exerciseId);
            }
          }
        });
        HapticFeedback.mediumImpact();
        _showRestCompleteNotification();
        }
    });
  }

  void _cancelRestTimer(String exerciseId) {
    _exerciseTimers[exerciseId]?.cancel();
    setState(() {
      _isExerciseResting[exerciseId] = false;
      _remainingRestTimes[exerciseId] = 0;

      // Complete the set when rest is skipped
    final exercise = _exerciseStates[exerciseId]!;
    final currentCompleted = exercise['completed'] as int;
      final totalSets = exercise['sets'] as int;
    
    if (currentCompleted < totalSets) {
        _exerciseStates[exerciseId]!['completed'] = currentCompleted + 1;
      _saveProgress();

      // Check if entire workout is completed
      bool allExercisesCompleted = _exerciseStates.values.every((exercise) {
          return exercise['completed'] >= exercise['sets'];
      });

      if (allExercisesCompleted) {
        setState(() {
            _isWorkoutCompleted = true;
            _showCompletionView = true;
        });
          _showWorkoutCompletionDialog();
        } else if (currentCompleted + 1 == totalSets) {
          _showExerciseCompletionMessage(exerciseId);
      }
    }
    });
  }

  void _completeSet(String exerciseId) {
    final exercise = _exerciseStates[exerciseId]!;
    final currentCompleted = exercise['completed'] as int;
    final totalSets = exercise['sets'] as int;
    final isSuperset = exercise['isSuperset'] == true;
    final supersetGroup = isSuperset ? exercise['supersetGroup'] as String : null;
    final supersetOrder = isSuperset ? exercise['supersetOrder'] as int : null;
    
    if (currentCompleted < totalSets) {
      if (isSuperset && supersetGroup != null && supersetOrder != null) {
        // Find all exercises in this superset
        final supersetExercises = _exerciseStates.entries
            .where((entry) => 
              entry.value['isSuperset'] == true && 
              entry.value['supersetGroup'] == supersetGroup)
            .toList()
          ..sort((a, b) => (a.value['supersetOrder'] as int)
              .compareTo(b.value['supersetOrder'] as int));
        
        // Find the next exercise in the superset
        final nextExercise = supersetExercises
            .firstWhere(
              (entry) => entry.value['supersetOrder'] == supersetOrder + 1,
              orElse: () => supersetExercises.first, // Wrap around to first exercise
            );
        
        // Check if this is the last exercise in the superset
        final isLastInSuperset = supersetOrder == supersetExercises
            .map((e) => e.value['supersetOrder'] as int)
            .reduce(max);
        
        setState(() {
          // Increment completed sets for current exercise
          _exerciseStates[exerciseId]!['completed'] = currentCompleted + 1;
          
          if (isLastInSuperset) {
            // If it's the last exercise in superset, start rest timer
        final restTime = int.parse(exercise['rest'].replaceAll(RegExp(r'[^0-9]'), ''));
        _startRestTimer(exerciseId, restTime);
          }
        });
        
        _saveProgress();
        
        // Check if entire workout is completed
        bool allExercisesCompleted = _exerciseStates.values.every((exercise) {
          return exercise['completed'] >= exercise['sets'];
        });
        
        if (allExercisesCompleted) {
          setState(() {
            _isWorkoutCompleted = true;
            _showCompletionView = true;
          });
          _showWorkoutCompletionDialog();
        } else if (currentCompleted + 1 == totalSets) {
          _showExerciseCompletionMessage(exerciseId);
      }
    } else {
        // Regular exercise - start rest timer immediately
      final restTime = int.parse(exercise['rest'].replaceAll(RegExp(r'[^0-9]'), ''));
      _startRestTimer(exerciseId, restTime);
      }
    }
  }

  void _showRestCompleteNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.timer_off, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Rest period complete! Ready for next set.'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showExerciseCompletionMessage(String exerciseId) {
    final exercise = _exerciseStates[exerciseId]!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('${exercise['name']} completed! Great work! 💪'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _resetWorkout() {
    // Cancel all active timers
    for (final timer in _exerciseTimers.values) {
      timer?.cancel();
    }
    
    setState(() {
      _exerciseStates.clear();
      _exerciseTimers.clear();
      _isExerciseResting.clear();
      _remainingRestTimes.clear();
      _isWorkoutCompleted = false;
      _showCompletionView = false;
      
      // Reinitialize with fresh states
      _initializeExerciseStates();
    });
  }

  Future<void> _showResetConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Reset Workout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to reset all workout progress? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetWorkout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                foregroundColor: Colors.red,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showWorkoutCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Workout Complete! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Great job completing your workout! Would you like to view your summary?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _showCompletionView = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'View Summary',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Today\'s Workout',
      userType: UserType.client,
      selectedNavIndex: _selectedNavIndex,
      selectedSubNavIndex: 0,
      subNavItems: _workoutSubNavItems,
      onNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/client/dashboard');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/client/workouts');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/client/ai-tools/chat');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/client/coach');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking');
            break;
          case 5:
            Navigator.pushReplacementNamed(context, '/client/progress-analytics');
            break;
        }
      },
      onSubNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/client/workouts');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/client/upcoming-workouts');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/client/workout-history');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/client/my-gym');
            break;
        }
      },
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF2D2D3A).withOpacity(0.45),
                  Color(0xFF1E1E28).withOpacity(0.45),
                  Color(0xFF0F0F17).withOpacity(0.45),
                ],
                stops: const [0.0, 0.5, 1.0],
                transform: GradientRotation(45 * 3.14 / 180),
              ),
            ),
          ),
          _showCompletionView ? _buildCompletionView() : _buildContent(),
        ],
      ),
    );
  }

  Widget _buildCompletionView() {
    return Container(
      padding: const EdgeInsets.all(24),
            child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
              children: [
          // Trophy achievement with enhanced visual effects
          Stack(
            alignment: Alignment.center,
              children: [
              // Outer glow ring
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.2),
                      const Color(0xFFFFD700).withOpacity(0),
                    ],
                    stops: const [0.7, 1.0],
                  ),
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).scale(
                duration: 2000.ms,
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
              ),
              
              // Inner trophy container with gradient
        Container(
                width: 160,
                height: 160,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
            ),
            child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 80,
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).shimmer(
                duration: 2000.ms,
                color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
          
          const SizedBox(height: 48),
          
          // Congratulations text with animation
          Column(
      children: [
              const Text(
                'Workout Complete!',
                style: TextStyle(
            color: Colors.white,
                  fontSize: 32,
            fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 8),
              
        Text(
                'You crushed it today! 💪',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.3, end: 0),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Action buttons with refined styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () => _showWorkoutSummary(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'View Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(delay: 800.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),
          
          // Recovery guide card with glass effect
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showStretchingGuide(context),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ).animate()
                            .scale(delay: 400.ms, duration: 400.ms)
                            .fadeIn(delay: 400.ms, duration: 400.ms),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recovery Guide Ready',
                            style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                              fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tailored stretches and tips for optimal recovery',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                    letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
                          ).animate()
                            .fadeIn(delay: 600.ms, duration: 400.ms)
                            .slideX(begin: 0.2, end: 0),

                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withOpacity(0.5),
                            size: 16,
                          ).animate()
                            .fadeIn(delay: 800.ms, duration: 400.ms)
                            .slideX(begin: 0.2, end: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ).animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
                      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildWorkoutOverview(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildWorkoutDetails(),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildWorkoutActions(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.00)),
      ),
      child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                  'Today\'s Workout',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                const SizedBox(height: 8),
                                        Text(
                  'Get ready for your daily fitness challenge',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
          ),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionButton(
          'Download Workout',
          Icons.download_rounded,
          AppTheme.primaryColor,
          onTap: () {
            // Download functionality
          },
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          'Share Workout',
          Icons.share_rounded,
          Colors.blue,
          onTap: () {
            // Share functionality
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(String tooltip, IconData icon, Color color, {VoidCallback? onTap}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  List<NavigationItem> get _workoutSubNavItems => [
    NavigationItem(
      icon: Icons.today,
      label: 'Today\'s Workout',
    ),
    NavigationItem(
      icon: Icons.calendar_today,
      label: 'Upcoming Workouts',
    ),
    NavigationItem(
      icon: Icons.history,
      label: 'Workout History',
    ),
    NavigationItem(
      icon: Icons.fitness_center_rounded,
      label: 'My Gym',
    ),
  ];

  Widget _buildWorkoutOverview() {
    // Count regular exercises and superset groups
    int regularExercises = 0;
    Set<String> supersetGroups = {};
    int totalCompletedSets = 0;
    int totalSets = 0;
    
    for (var exercise in _todaysWorkout['exercises']) {
      if (exercise['isSuperset'] == true) {
        supersetGroups.add(exercise['supersetGroup']);
      } else {
        regularExercises++;
      }
      
      final exerciseId = exercise['name'] as String;
      final sets = exercise['sets'] as int;
      totalSets += sets;
      totalCompletedSets += (_exerciseStates[exerciseId]?['completed'] ?? 0) as int;
    }
    
    final totalExercises = regularExercises + supersetGroups.length;
    final exerciseText = '$totalExercises ${totalExercises == 1 ? 'Exercise' : 'Exercises'}';
    final progress = totalSets > 0 ? totalCompletedSets / totalSets : 0.0;
    final progressPercent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.00)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout Title
          Text(
            _todaysWorkout['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Muscle Groups
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_todaysWorkout['muscleGroups'] as List<dynamic>).map((group) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                                  ),
                                ),
                                  child: Text(
                  group,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildOverviewStat(
                'Exercises',
                exerciseText,
                Icons.fitness_center_rounded,
                Colors.green,
              ),
              const SizedBox(width: 24),
              _buildOverviewStat(
                'Duration',
                _todaysWorkout['duration'],
                Icons.timer,
                Colors.blue,
              ),
              const SizedBox(width: 24),
              _buildOverviewStat(
                'Calories',
                '${_todaysWorkout['calories']} kcal',
                Icons.local_fire_department_rounded,
                Colors.red,
              ),
              const SizedBox(width: 24),
              _buildOverviewStat(
                'Intensity',
                _todaysWorkout['difficulty'],
                Icons.speed_rounded,
                Colors.orange,
                              ),
                            ],
                          ),
          const SizedBox(height: 16),
          Row(
                            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Workout Progress',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$progressPercent%',
                          style: TextStyle(
                            color: progressPercent == 100 ? Colors.green : AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressPercent == 100 ? Colors.green : AppTheme.primaryColor,
                        ),
                        minHeight: 8,
                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, IconData icon, Color color) {
    return Expanded(
                    child: Container(
        padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
                        border: Border.all(
            color: color.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
              padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
                          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                              style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.00)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Workout Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Complete Workout Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isWorkoutCompleted = true;
                        _showCompletionView = true;
                      });
                      _showWorkoutCompletionDialog();
                    },
            style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Complete Workout'),
                  ),
                  const SizedBox(width: 12),
                  // Reset Button
                  IconButton(
            onPressed: _showResetConfirmationDialog,
                    icon: const Icon(Icons.refresh),
                    style: IconButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // View Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        _buildViewToggleButton(
                          icon: Icons.view_list,
                          isSelected: _isListView,
                          onTap: () => setState(() => _isListView = true),
                        ),
                        _buildViewToggleButton(
                          icon: Icons.grid_view,
                          isSelected: !_isListView,
                          onTap: () => setState(() => _isListView = false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildWorkoutSection(
            'Warm Up',
            _todaysWorkout['warmup']['duration'],
            _todaysWorkout['warmup']['exercises'],
            Colors.orange,
          ),
          const SizedBox(height: 24),
          _isListView ? _buildExercisesListView(_todaysWorkout['exercises']) : _buildExercisesCardView(_todaysWorkout['exercises']),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.5),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildExercisesListView(List<dynamic> exercises) {
    // Group exercises by superset
    Map<String?, List<Map<String, dynamic>>> supersetGroups = {};
    for (var exercise in exercises) {
      final supersetGroup = exercise['isSuperset'] == true ? exercise['supersetGroup'] as String : null;
      if (!supersetGroups.containsKey(supersetGroup)) {
        supersetGroups[supersetGroup] = [];
      }
      supersetGroups[supersetGroup]!.add(Map<String, dynamic>.from(exercise));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                _buildListHeader('#', flex: 1),
                _buildListHeader('Exercise', flex: 3),
                _buildListHeader('Sets', flex: 1),
                _buildListHeader('Reps', flex: 1),
                _buildListHeader('Weight', flex: 1),
                _buildListHeader('Rest', flex: 1),
              ],
            ),
          ),
          // Exercise rows grouped by superset
          ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
            itemCount: supersetGroups.length,
            itemBuilder: (context, groupIndex) {
              final groupKey = supersetGroups.keys.elementAt(groupIndex);
              final groupExercises = supersetGroups[groupKey]!;
              
              if (groupKey == null) {
                // Regular exercises
                return Column(
                  children: groupExercises.map((exercise) {
                    final index = exercises.indexOf(exercise) + 1;
                    return _buildExerciseListItem(exercise, index);
      }).toList(),
    );
              } else {
                // Superset exercises
    return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
                        AppTheme.secondaryColor.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
                    borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.3),
                    ),
                  ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.secondaryColor.withOpacity(0.2),
                            AppTheme.secondaryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.secondaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sync_alt,
                            color: AppTheme.secondaryColor.withOpacity(0.9),
                                    size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Superset',
                            style: TextStyle(
                              color: AppTheme.secondaryColor.withOpacity(0.9),
                                      fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                                'Complete one set of each exercise, then rest',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                      ...groupExercises.asMap().entries.map((entry) {
                        final exercise = entry.value;
                        final index = exercises.indexOf(exercise) + 1;
                        final isLastInSuperset = entry.key == groupExercises.length - 1;
                        
                        return Column(
                          children: [
                            _buildExerciseListItem(exercise, index),
                            if (!isLastInSuperset) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 24,
                                        child: Center(
                                          child: Icon(
                                            Icons.arrow_downward,
                                            color: AppTheme.secondaryColor.withOpacity(0.5),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
            ],
          ),
        ),
                            ],
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseListItem(Map<String, dynamic> exercise, int index) {
    final exerciseId = exercise['name'] as String;
    final exerciseState = _exerciseStates[exerciseId];
    final completedSets = exerciseState?['completed'] ?? 0;
    final totalSets = exercise['sets'] as int;
    final progress = completedSets / totalSets;
    final isSuperset = exercise['isSuperset'] == true;

    return InkWell(
      onTap: () => _showExerciseDetails(exerciseId, exercise),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                index.toString(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
        exercise['name'],
        style: const TextStyle(
          color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '$completedSets/${exercise['sets']}',
                style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                            ),
                          ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                exercise['reps'],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                            ),
                          ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                exercise['weights'][0],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                exercise['rest'],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseDetails(String exerciseId, Map<String, dynamic> exercise, {double animateFrom = 0.0}) {
    final completedSets = _exerciseStates[exerciseId]?['completed'] ?? 0;
    final totalSets = exercise['sets'] as int;
    final isSuperset = exercise['isSuperset'] == true;
    final supersetGroup = isSuperset ? exercise['supersetGroup'] as String? : null;
    final supersetOrder = isSuperset ? exercise['supersetOrder'] as int? : null;

    // Get ordered exercises list for navigation
    final orderedExercises = _todaysWorkout['exercises'] as List<dynamic>;
    final currentIndex = orderedExercises.indexWhere((e) => e['name'] == exerciseId);
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < orderedExercises.length - 1;

    // Get superset info if applicable
    List<Map<String, dynamic>> supersetExercises = [];
    if (isSuperset && supersetGroup != null) {
      supersetExercises = orderedExercises
          .where((e) => 
              e['isSuperset'] == true && 
              e['supersetGroup'] == supersetGroup)
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
          ..sort((a, b) => (a['supersetOrder'] as int).compareTo(b['supersetOrder'] as int));
    }

    void navigateToExercise(String targetExerciseId, Map<String, dynamic> targetExercise, double animationOffset) {
      Navigator.of(context).pop();
      _showExerciseDetails(targetExerciseId, targetExercise, animateFrom: animationOffset);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            void rebuildModal() {
              setModalState(() {});
            }

            if (_isExerciseResting[exerciseId] == true) {
              Future.delayed(const Duration(milliseconds: 100), () {
                rebuildModal();
              });
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  child: Column(
              children: [
                            // Handle bar
                Container(
                              margin: const EdgeInsets.only(top: 8),
                  width: 40,
                              height: 4,
                  decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            
                      // Make everything scrollable
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          children: [
                            // Exercise header with navigation
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  // Previous exercise arrow
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: hasPrevious ? 1.0 : 0.0,
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                      onPressed: hasPrevious
                                        ? () {
                                            final prevExercise = orderedExercises[currentIndex - 1];
                                            navigateToExercise(prevExercise['name'], prevExercise, -1.0);
                                          }
                                        : null,
                                    ),
                                  ),
                                  
                Expanded(
                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                                        Text(
                                          exercise['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${exercise['sets']} sets × ${exercise['reps']} | Rest: ${exercise['rest']}',
                                style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Next exercise arrow
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: hasNext ? 1.0 : 0.0,
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                      onPressed: hasNext
                                        ? () {
                                            final nextExercise = orderedExercises[currentIndex + 1];
                                            navigateToExercise(nextExercise['name'], nextExercise, 1.0);
                                          }
                                        : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quick Actions
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  _buildDetailActionButton(
                                    label: 'Watch Video',
                                    icon: Icons.play_circle_outline,
                                    onPressed: () {
                                      // Show video demonstration
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  _buildDetailActionButton(
                                    label: 'Ask Coach',
                                    icon: Icons.message_outlined,
                                    onPressed: () => _askCoach(exercise),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildDetailActionButton(
                                    label: 'Ask AI',
                                    icon: Icons.psychology,
                                    onPressed: () => _askAI(exercise),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildDetailActionButton(
                                    label: 'Form Check',
                                    icon: Icons.camera_outlined,
                                    onPressed: () => _handleFormCheck(exercise['name']),
                                    isBeta: true,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Rest of the content...
                            if (isSuperset && supersetExercises.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.secondaryColor.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.secondaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.secondaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.sync_alt,
                                              color: AppTheme.secondaryColor,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Superset Flow',
                                            style: TextStyle(
                                              color: AppTheme.secondaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          ...supersetExercises.asMap().entries.map((entry) {
                                            final isCurrentExercise = entry.value['name'] == exerciseId;
                                            final isLastExercise = entry.key == supersetExercises.length - 1;

                                            return Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: isCurrentExercise ? null : () {
                                                        navigateToExercise(
                                                          entry.value['name'],
                                                          entry.value,
                                                          entry.key > currentIndex ? 1.0 : -1.0,
                                                        );
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: 8,
                                                          horizontal: 12,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: isCurrentExercise
                                                              ? AppTheme.secondaryColor.withOpacity(0.2)
                                                              : Colors.transparent,
                                                          border: Border.all(
                                                            color: isCurrentExercise
                                                                ? AppTheme.secondaryColor
                                                                : Colors.white.withOpacity(0.3),
                                                          ),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          entry.value['name'],
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            color: isCurrentExercise
                                                                ? AppTheme.secondaryColor
                                                                : Colors.white.withOpacity(0.7),
                                                            fontSize: 12,
                                                            fontWeight: isCurrentExercise
                                                                ? FontWeight.bold
                                                                : FontWeight.normal,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (!isLastExercise) ...[
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      Icons.arrow_forward,
                                                      color: Colors.white.withOpacity(0.3),
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 8),
                                                  ],
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Complete one set of each exercise, then rest',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            
                            // Trainer Notes
                            if (exercise['notes'] != null) ...[
                Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Container(
                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: AppTheme.primaryColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Trainer Notes',
                                            style: TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                          Text(
                                        exercise['notes'],
                                        style: const TextStyle(
                              color: AppTheme.primaryColor,
                                          fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            
                            // Sets Progress
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sets Progress',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...List.generate(
                                    totalSets,
                                    (index) => _buildSetProgressItem(
                                      exerciseId,
                                      exercise,
                                      index,
                                      completedSets,
                                      onSetCompleted: (exerciseId, newCompletedSets) {
                                        if (isSuperset && supersetGroup != null && supersetOrder != null) {
                                          final isLastInSuperset = !orderedExercises.any((e) => 
                                            e['isSuperset'] == true && 
                                            e['supersetGroup'] == supersetGroup && 
                                            e['supersetOrder'] == supersetOrder + 1);

                                          if (!isLastInSuperset) {
                                            // Complete the set immediately for non-last superset exercises
                                            _completeSet(exerciseId);
                                            
                                            // Find and navigate to the next exercise in the superset
                                            final nextExercise = orderedExercises.firstWhere(
                                              (e) => 
                                                e['isSuperset'] == true && 
                                                e['supersetGroup'] == supersetGroup && 
                                                e['supersetOrder'] == supersetOrder + 1
                                            );
                                            navigateToExercise(nextExercise['name'], nextExercise, 1.0);
                                          } else {
                                            // Start rest timer for last exercise in superset
                                            final restTime = int.parse(exercise['rest'].replaceAll(RegExp(r'[^0-9]'), ''));
                                            _startRestTimer(exerciseId, restTime);
                                            rebuildModal();
                                          }
                                        } else {
                                          // Normal rest timer for non-superset exercises
                                          final restTime = int.parse(exercise['rest'].replaceAll(RegExp(r'[^0-9]'), ''));
                                          _startRestTimer(exerciseId, restTime);
                                          rebuildModal();
                                        }
                                      },
                                      onSkipRest: () {
                                        _cancelRestTimer(exerciseId);
                                        rebuildModal();
                                      },
                        ),
                      ),
                    ],
                  ),
                ),
                            const SizedBox(height: 24),
              ],
                        ),
            ),
        ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isBeta = false,
  }) {
    return Container(
      height: 36.0,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF2A2A2A),
          foregroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: AppTheme.primaryColor,
              width: 1.5,
            ),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Row(
          children: [
          Text(
            label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isBeta) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BETA',
            style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesCardView(List<dynamic> exercises) {
    // Group exercises by superset
    Map<String?, List<Map<String, dynamic>>> supersetGroups = {};
    for (var exercise in exercises) {
      final supersetGroup = exercise['isSuperset'] == true ? exercise['supersetGroup'] as String : null;
      if (!supersetGroups.containsKey(supersetGroup)) {
        supersetGroups[supersetGroup] = [];
      }
      supersetGroups[supersetGroup]!.add(Map<String, dynamic>.from(exercise));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70, // Changed from 0.85 to 0.70 for taller cards
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final isSuperset = exercise['isSuperset'] == true;
        final supersetGroup = isSuperset ? exercise['supersetGroup'] as String : null;
        final supersetOrder = isSuperset ? exercise['supersetOrder'] as int : null;
        
        // Cast the superset exercises to the correct type
        final List<Map<String, dynamic>> typedSupersetExercises = isSuperset 
            ? supersetGroups[supersetGroup]?.map((e) => Map<String, dynamic>.from(e)).toList() ?? []
            : [];
        
        return _buildExerciseCard(
          exercise,
          index + 1,
          supersetExercises: typedSupersetExercises,
          currentSupersetOrder: supersetOrder,
        );
      },
    );
  }

  Widget _buildExerciseCard(
    Map<String, dynamic> exercise,
    int index, {
    List<Map<String, dynamic>> supersetExercises = const [],
    int? currentSupersetOrder,
  }) {
    final exerciseId = exercise['name'] as String;
    final exerciseState = _exerciseStates[exerciseId];
    final isResting = _isExerciseResting[exerciseId] ?? false;
    final remainingTime = _remainingRestTimes[exerciseId] ?? 0;
    final completedSets = exerciseState?['completed'] ?? 0;
    final totalSets = exercise['sets'] as int;
    final progress = completedSets / totalSets;
    final isSuperset = exercise['isSuperset'] == true;
    final supersetGroup = isSuperset ? exercise['supersetGroup'] as String : null;

    return Container(
                        decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
          color: isSuperset 
              ? AppTheme.secondaryColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
        ),
      ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
                                children: [
              // Header section with exercise name and superset indicator
                                  Container(
                padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                  gradient: isSuperset
                      ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                            AppTheme.secondaryColor.withOpacity(0.1),
                              Colors.transparent,
                            ],
                        )
                      : null,
                ),
                                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                                                      decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                          child: Text(
                            '#$index',
                                                      style: TextStyle(
                                                        color: AppTheme.primaryColor,
                              fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                        ),
                        if (exercise['notes'] != null)
                          IconButton(
                            onPressed: () => _showExerciseDetails(exerciseId, exercise),
                            icon: Icon(
                              Icons.info_outline,
                              color: Colors.white.withOpacity(0.5),
                              size: 16,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                            tooltip: 'Trainer Notes',
                          ),
                      ],
          ),
          const SizedBox(height: 12),
                          Text(
                      exercise['name'],
                style: const TextStyle(
                            color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                                  ),
                                ),
            ],
          ),
              ),

              // Superset flow visualization
              if (isSuperset && supersetExercises.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (var i = 0; i < supersetExercises.length; i++) ...[
                            if (i > 0) ...[
                              Container(
                                width: 24,
                                child: Divider(
                                  color: AppTheme.secondaryColor.withOpacity(0.5),
                                  thickness: 2,
                                ),
                              ),
                            ],
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: supersetExercises[i]['name'] == exercise['name']
                                      ? AppTheme.secondaryColor.withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: supersetExercises[i]['name'] == exercise['name']
                                        ? AppTheme.secondaryColor
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        color: supersetExercises[i]['name'] == exercise['name']
                                            ? AppTheme.secondaryColor
                                            : Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      supersetExercises[i]['name'],
                                      style: TextStyle(
                                        color: supersetExercises[i]['name'] == exercise['name']
                                            ? AppTheme.secondaryColor
                                            : Colors.white.withOpacity(0.5),
                                        fontSize: 11,
                                        fontWeight: supersetExercises[i]['name'] == exercise['name']
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.secondaryColor.withOpacity(0.7),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Complete one set of each exercise, then rest',
                              style: TextStyle(
                                color: AppTheme.secondaryColor.withOpacity(0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Progress and timer section
                                      Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                          'Progress',
                                          style: TextStyle(
                                                  color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                                          ),
                                        ),
                                                  Text(
                          '$completedSets/$totalSets sets',
                                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completedSets == totalSets ? Colors.green : AppTheme.primaryColor,
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isResting) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.orange,
                                                size: 14,
                                              ),
                            const SizedBox(width: 6),
                                              Text(
                              'Rest: ${_formatTime(remainingTime)}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () => _cancelRestTimer(exerciseId),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              child: const Text(
                                'Skip',
                                          style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (completedSets < totalSets) ...[
                      ElevatedButton(
                        onPressed: () => _completeSet(exerciseId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                            const Icon(Icons.check_circle_outline, size: 16),
                            const SizedBox(width: 8),
                                                      Text(
                              'Complete Set ${completedSets + 1}',
                                                        style: const TextStyle(
                                fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                    ],
                  ],
                ),
              ),

              // Sets and weights section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                        'Sets',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                                      fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                                  ),
                      const SizedBox(height: 8),
                                                              Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              totalSets,
                              (setIndex) => _buildSetChip(
                                setIndex + 1,
                                exercise['weights'][setIndex],
                                exercise['reps'],
                                isCompleted: setIndex < completedSets,
                                isCurrent: setIndex == completedSets,
                              ),
                            ),
                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),

              // Action buttons in a scrollable row
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildExerciseActionButton(
                      'Video',
                      Icons.play_circle_outline,
                      Colors.blue,
                      onPressed: () {
                        // Implement video playback
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildExerciseActionButton(
                      'Coach',
                      Icons.message_outlined,
                      Colors.green,
                      onPressed: () => _askCoach(exercise),
                    ),
                    const SizedBox(width: 8),
                    _buildExerciseActionButton(
                      'AI',
                      Icons.psychology_outlined,
                      Colors.purple,
                      onPressed: () => _askAI(exercise),
                    ),
                    const SizedBox(width: 8),
                    _buildExerciseActionButton(
                      'Form',
                      Icons.camera_outlined,
                      Colors.orange,
                      onPressed: () => _handleFormCheck(exercise['name']),
                      isBeta: true,
                                                        ),
                                                      ],
                                                    ),
                                              ),
              const SizedBox(height: 16),
                                          ],
                                        ),
                                  ),
                                ),
                              );
  }

  Widget _buildSetChip(int setNumber, String weight, String reps, {
    required bool isCompleted,
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : (isCurrent ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.3)
              : (isCurrent ? AppTheme.primaryColor.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                                    ),
                                  ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
                                    children: [
          Text(
            'Set $setNumber',
                                        style: TextStyle(
              color: isCompleted
                  ? Colors.green
                  : (isCurrent ? AppTheme.primaryColor : Colors.white.withOpacity(0.7)),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
        Text(
            '• $weight × $reps',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 12,
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildExerciseActionButton(
    String label,
    IconData icon,
    Color color, {
    required VoidCallback onPressed,
    bool isBeta = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
        ),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: color.withOpacity(0.3),
          ),
        ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
                color: color,
                size: 16,
            ),
              const SizedBox(width: 8),
            Text(
              label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isBeta) ...[
                const SizedBox(width: 4),
                      Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                        decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BETA',
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
              ],
            ],
          ),
                                    ),
                                  ),
                                );
  }

  Widget _buildWorkoutActions() {
                              return Container(
      padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.00)),
                          ),
                          child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                          const Text(
            'Quick Actions',
                                          style: TextStyle(
                                              color: Colors.white,
              fontSize: 18,
                                              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildActionCard(
            'Start Workout',
            'Begin your training session',
            Icons.play_circle_outline,
            AppTheme.primaryColor,
            onTap: () {
              // Start workout logic
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            'View Exercise Guide',
            'Detailed form instructions',
            Icons.menu_book,
            Colors.blue,
            onTap: () {
              // Show exercise guide
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            'Ask AI Coach',
            'Get personalized guidance',
            Icons.psychology,
            Colors.purple,
            onTap: () {
              // Open AI chat
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            'Schedule Reminder',
            'Set workout notification',
            Icons.notifications_active,
            Colors.orange,
            onTap: () {
              // Set reminder
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
          child: Container(
          padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
              border: Border.all(
              color: color.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                  icon,
                        color: color,
                  size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                        fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                      subtitle,
                        style: TextStyle(
                                                      color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                                              Icon(
                Icons.chevron_right,
                color: color,
                    size: 20,
                ),
              ],
            ),
          ),
        ),
                              );
  }

  Widget _buildWorkoutSection(String title, String duration, List<dynamic> exercises, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
          color: color.withOpacity(0.3),
                                          ),
                                        ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                                Container(
                padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  title == 'Warm Up' ? Icons.whatshot : Icons.ac_unit,
                  color: color,
                                                    size: 20,
                                                  ),
                                                ),
              const SizedBox(width: 12),
                                                Text(
                title,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                  ),
                                                ),
              const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(
                    color: color.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Text(
                  duration,
                                                    style: TextStyle(
                    color: color,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
          ...exercises.map((exercise) => Padding(
                                                          padding: const EdgeInsets.only(bottom: 8),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: 6,
                                                                height: 6,
                                                                decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 12),
                                                  Text(
                  exercise,
                                                                  style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                                                    fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )).toList(),
                                                      ],
                                                    ),
                                                        );
  }

  Widget _buildListHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
                                                          style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
                                                            fontWeight: FontWeight.w600,
                                                          ),
      ),
    );
  }

  void _askCoach(Map<String, dynamic> exercise) {
    // Navigate to coach chat with pre-filled message
    Navigator.pushNamed(
      context,
      '/client/coach',
      arguments: {
        'initialMessage': 'Hi Coach, I have a question about ${exercise['name']}...',
      },
    );
  }

  void _askAI(Map<String, dynamic> exercise) {
    // Navigate to AI chat with exercise context
    Navigator.pushNamed(
      context,
      '/client/ai-tools/chat',
      arguments: {
        'context': {
          'exercise': exercise['name'],
          'sets': exercise['sets'],
          'reps': exercise['reps'],
          'notes': exercise['notes'],
        },
        'initialMessage': 'I need help with proper form for ${exercise['name']}...',
      },
    );
  }

  Widget _buildSetProgressItem(
    String exerciseId,
    Map<String, dynamic> exercise,
    int setIndex,
    int completedSets, {
    required Function(String, int) onSetCompleted,
    required VoidCallback onSkipRest,
  }) {
    final isCompleted = setIndex < completedSets;
    final isCurrent = setIndex == completedSets;
    final weights = exercise['weights'] as List<dynamic>;
    final isResting = _isExerciseResting[exerciseId] ?? false;
    final remainingTime = _remainingRestTimes[exerciseId] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
          color: isCompleted
              ? AppTheme.secondaryColor.withOpacity(0.5)
              : (isCurrent
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1)),
                                    ),
                                  ),
          child: Column(
            children: [
              Row(
                children: [
        Text(
                'Set ${setIndex + 1}',
                      style: TextStyle(
                  color: isCompleted
                      ? AppTheme.secondaryColor
                      : (isCurrent ? AppTheme.primaryColor : Colors.white),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
        Text(
                '${exercise['reps']} @ ${weights[setIndex]}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.secondaryColor,
                  size: 20,
                )
              else if (isCurrent)
                ElevatedButton(
                  onPressed: isResting
                      ? onSkipRest
                      : () => onSetCompleted(exerciseId, completedSets + 1),
      style: ElevatedButton.styleFrom(
                    backgroundColor: isResting 
                        ? Colors.red.withOpacity(0.2)
                        : AppTheme.primaryColor.withOpacity(0.2),
                    foregroundColor: isResting 
                        ? Colors.red 
                        : AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
        ),
        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isResting ? 'Skip Rest' : 'Complete Set',
                  ),
            ),
          ],
        ),
          if (isResting && isCurrent) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.timer,
              color: AppTheme.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Rest: ${_formatTime(remainingTime)}',
                                  style: const TextStyle(
                color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showWorkoutSummary(BuildContext context) {
    showDialog(
                                      context: context,
      builder: (BuildContext context) {
        // Calculate workout statistics
        int totalExercises = _todaysWorkout['exercises'].length;
        int totalSets = 0;
        int completedSets = 0;
        
        for (var exercise in _todaysWorkout['exercises']) {
          final exerciseId = exercise['name'] as String;
          final sets = exercise['sets'] as int;
          totalSets += sets;
          completedSets += (_exerciseStates[exerciseId]?['completed'] ?? 0) as int;
        }
        
        double completionPercentage = (completedSets / totalSets) * 100;
        
        return Dialog(
          backgroundColor: const Color(0xFF2A2A2A),
                shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
                          child: Column(
                    mainAxisSize: MainAxisSize.min,
                            children: [
                const Text(
                  'Workout Summary',
                  style: TextStyle(
                                  color: Colors.white,
                                          fontSize: 24,
                                  fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSummaryItem(
                  'Total Exercises',
                  '$totalExercises',
                  Icons.fitness_center,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildSummaryItem(
                  'Sets Completed',
                  '$completedSets/$totalSets',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildSummaryItem(
                  'Completion',
                  '${completionPercentage.toStringAsFixed(1)}%',
                  Icons.pie_chart,
                                                    AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                _buildSummaryItem(
                  'Duration',
                  _todaysWorkout['duration'],
                                          Icons.timer,
                  Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildSummaryItem(
                  'Calories Burned',
                  '${_todaysWorkout['calories']} kcal',
                  Icons.local_fire_department,
                  Colors.red,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                                        child: Text(
                        'Close',
                                            style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Add share functionality here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Share Results'),
                    ),
                  ],
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
            color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
            icon,
                        color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
                Expanded(
                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                      Text(
                label,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
    );
  }

  void _showStretchingGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF2A2A2A),
                                                shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                                                ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                              children: [
                                Container(
                    padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                      Icons.self_improvement,
                      color: AppTheme.primaryColor,
                        size: 32,
                    ),
                                ),
                                const SizedBox(width: 16),
                  const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                          Text(
                            'Recovery Guide',
                                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                          SizedBox(height: 4),
                                      Text(
                            'Personalized stretching routine',
                                        style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                const SizedBox(height: 24),
                _buildStretchingSection(
                  'Lower Body Stretches',
                  [
                    'Hamstring Stretch - 30 seconds each leg',
                    'Quad Stretch - 30 seconds each leg',
                    'Calf Stretch - 30 seconds each leg',
                    'Hip Flexor Stretch - 30 seconds each side',
                  ],
                  Icons.accessibility_new,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildStretchingSection(
                  'Recovery Tips',
                  [
                    'Stay hydrated throughout the day',
                    'Get 7-8 hours of sleep tonight',
                    'Consider using a foam roller',
                    'Light walking or cycling tomorrow',
                  ],
                  Icons.tips_and_updates,
                  Colors.blue,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
            Navigator.pop(context);
                        // Navigate to detailed recovery guide
                      },
      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('View Full Guide'),
                    ),
                  ],
                ),
              ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildStretchingSection(String title, List<String> items, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          Row(
        children: [
          Icon(
                icon,
            color: color,
                size: 20,
          ),
                              const SizedBox(width: 12),
          Text(
                title,
            style: TextStyle(
              color: color,
                                  fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                  width: 6,
                  height: 6,
      decoration: BoxDecoration(
                    color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                    item,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  ),
            ),
          ),
        ],
      ),
          )).toList(),
        ],
      ),
    );
  }

  void _handleFormCheck(String exerciseName) {
    if (kIsWeb) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          title: const Text(
            'Form Check Not Available on Web',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Download our mobile app to use this feature.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => FormCheckDialog(exerciseName: exerciseName),
      );
    }
  }
} 