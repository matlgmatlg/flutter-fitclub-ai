import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/user_type.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/app_navigation.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_animations/simple_animations.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  // Exercise state management
  final Map<String, Map<String, dynamic>> _exerciseStates = {};
  final Map<String, Timer?> _exerciseTimers = {};
  final Map<String, bool> _isExerciseResting = {};
  final Map<String, int> _remainingRestTimes = {};
  static const String _workoutProgressKey = 'workout_progress';
  bool _isCardView = false;
  bool _isWorkoutCollapsed = false;
  // Track expanded info sections
  final Set<String> _expandedInfoSections = {};

  // Recovery protocol data
  final List<Map<String, dynamic>> recoveryData = [
    {
      'title': 'Cool Down',
      'timing': '5 minutes',
      'type': 'cardio',
      'why': [
        'Improves circulation & flushes metabolic waste',
        'Reduces post-workout tightness & stiffness',
        'Helps transition from high-intensity to recovery mode'
      ],
      'note': 'Optional for Medium-High Intensity Workouts',
      'exercises': [
        {
          'name': 'Light Walking',
          'icon': Icons.directions_walk,
          'duration': '3-5 minutes',
          'description': 'Maintain a comfortable pace to gradually cool down.',
          'intensity': 'Low',
          'tips': 'Focus on deep breathing and maintaining good posture.'
        },
        {
          'name': 'Light Cycling',
          'icon': Icons.pedal_bike,
          'duration': '3-5 minutes',
          'description': 'Keep resistance low and maintain an easy pace.',
          'intensity': 'Low',
          'tips': 'Use this time to mentally review your workout achievements.'
        }
      ]
    },
    {
      'title': 'Hydration',
      'timing': 'Within 30 min',
      'type': 'nutrition',
      'why': [
        'Replenishes lost fluids & electrolytes',
        'Prevents muscle cramps & fatigue',
        'Aids protein synthesis & overall recovery'
      ],
      'note': 'Essential for Recovery',
      'recommendations': [
        {
          'name': 'Water Intake',
          'icon': Icons.water_drop,
          'target': '16-20 oz',
          'timing': ' 16-20 oz',
          'details': 'Consider adding electrolytes if workout was intense.'
        }
      ]
    },
    {
      'title': 'Protein Intake',
      'timing': 'Within 120 Minutes',
      'type': 'nutrition',
      'why': [
        'Stimulates muscle protein synthesis (MPS)',
        'Prevents muscle breakdown (catabolism)',
        'Supports faster recovery & strength gains'
      ],
      'note': 'Critical for Muscle Recovery',
      'recommendations': [
        {
          'name': 'Post-Workout Nutrition',
          'icon': Icons.restaurant,
          'target': '30-40g protein',
          'timing': 'Within 2 hours',
          'details': 'Consume a balanced meal or protein shake containing 30-40g of protein and complex carbohydrates.'
        }
      ]
    },
    {
      'title': 'Evening Stretching',
      'timing': 'Before bed',
      'type': 'mobility',
      'why': [
        'Prevents stiffness & joint pain the next day',
        'Improves flexibility & recovery',
        'Supports better sleep by activating the parasympathetic nervous system'
      ],
      'note': 'Enhancing Mobility & Reducing Tightness',
      'exercises': [
        {
          'name': 'Standing Quad Stretch',
          'icon': Icons.accessibility_new,
          'duration': '30 seconds each side',
          'sets': '2-3 sets',
          'description': 'Hold your foot behind your back, keeping knees together.',
          'muscle': 'Quadriceps',
          'execution': [
            'Stand on one leg, bend your other knee',
            'Hold your foot behind your back',
            'Keep your knees close together',
            'Maintain an upright posture'
          ],
          'tips': 'Use a wall or chair for balance if needed.',
          'intensity': 'Gentle stretch'
        },
        {
          'name': 'Romanian Deadlift Stretch',
          'icon': Icons.accessibility_new,
          'duration': '30 seconds',
          'sets': '2-3 sets',
          'description': 'Hinge at hips while keeping legs straight.',
          'muscle': 'Hamstrings',
          'execution': [
            'Stand with feet hip-width apart',
            'Keep legs straight but not locked',
            'Hinge at hips, reaching for toes',
            'Maintain a flat back'
          ],
          'tips': 'Bend knees slightly if feeling too much tension.',
          'intensity': 'Moderate stretch'
        },
        {
          'name': 'Kneeling Hip Flexor Stretch',
          'icon': Icons.accessibility_new,
          'duration': '30 seconds each side',
          'sets': '2-3 sets',
          'description': 'Kneel on one knee, push hips forward.',
          'muscle': 'Hip Flexors',
          'execution': [
            'Kneel on one knee',
            'Keep front foot flat',
            'Push hips forward gently',
            'Maintain upright posture'
          ],
          'tips': 'Place cushion under knee for comfort.',
          'intensity': 'Moderate stretch'
        }
      ]
    },
    {
      'title': 'Sleep Goal',
      'timing': 'Tonight',
      'type': 'recovery',
      'why': [
        '90% of muscle repair & growth happens during deep sleep',
        'Increases testosterone & growth hormone production',
        'Reduces cortisol (stress hormone) → better recovery'
      ],
      'note': 'The #1 Recovery Factor',
      'recommendations': [
        {
          'name': 'Quality Sleep',
          'icon': Icons.bedtime,
          'target': '7-9 hours',
          'timing': '7-9 hours of quality sleep',
          'details': 'Keep room cool and dark, avoid screens 1 hour before bed.'
        }
      ]
    }
  ];

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
      icon: Icons.analytics,
      label: 'Progress Analytics',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeExerciseStates(); // Initialize states immediately
    _loadSavedProgress(); // Then try to load saved progress
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
    final exercises = _getExercises();
    setState(() {
      _exerciseStates.clear(); // Clear existing states
      for (final exercise in exercises) {
        final exerciseId = exercise['name'];
        _exerciseStates[exerciseId] = {
          ...exercise,
          'completed': exercise['completed'] ?? 0,
        };
        _isExerciseResting[exerciseId] = false;
        _remainingRestTimes[exerciseId] = 0;
      }
    });
    _saveProgress(); // Save initial state
  }

  @override
  void dispose() {
    // Cancel all active timers
    for (final timer in _exerciseTimers.values) {
      timer?.cancel();
    }
    super.dispose();
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
          _completeSet(exerciseId);
        });
        }
    });
  }

  void _cancelRestTimer(String exerciseId) {
    _exerciseTimers[exerciseId]?.cancel();
    setState(() {
      _isExerciseResting[exerciseId] = false;
      _remainingRestTimes[exerciseId] = 0;
      _completeSet(exerciseId); // Complete the set when rest is skipped
    });
  }

  void _completeSet(String exerciseId) {
    final exercise = _exerciseStates[exerciseId]!;
    final currentCompleted = exercise['completed'] as int;
    final totalSets = int.parse(exercise['sets']);
    
    if (currentCompleted < totalSets) {
    setState(() {
        _exerciseStates[exerciseId]?['completed'] = currentCompleted + 1;
      });
      _saveProgress();

      // Check if entire workout is completed
      bool allExercisesCompleted = _exerciseStates.values.every((exercise) {
        return exercise['completed'] >= int.parse(exercise['sets']);
      });

      if (allExercisesCompleted) {
        setState(() {
          _isWorkoutCollapsed = true;
        });
      }
    }
  }

  void _updateExerciseProgress(String exerciseId, int completedSets) {
    final exercise = _exerciseStates[exerciseId]!;
    final totalSets = int.parse(exercise['sets']);
    final isSuperset = exercise['isSuperset'] == true;
    final supersetGroup = isSuperset ? exercise['supersetGroup'] as String? : null;
    final supersetOrder = isSuperset ? exercise['supersetOrder'] as int? : null;
    
    if (completedSets > totalSets) {
      _showCompletionNotification(
        context,
        'Great job completing ${exercise['name']}! 💪',
      );
      return;
    }

    // Handle superset logic
    if (isSuperset && supersetGroup != null && supersetOrder != null) {
      final isLastInSuperset = !_exerciseStates.values.any((e) => 
        e['isSuperset'] == true && 
        e['supersetGroup'] == supersetGroup && 
        e['supersetOrder'] == supersetOrder + 1);

      if (!isLastInSuperset) {
        // For non-last exercises in superset, complete set without rest
        _completeSet(exerciseId);
      } else {
        // For last exercise in superset, start rest timer
        final restTime = int.parse(exercise['rest'].replaceAll(RegExp(r'[^0-9]'), ''));
        _startRestTimer(exerciseId, restTime);
      }
    } else {
      // Normal exercise - start rest timer
      final restTime = int.parse(exercise['rest'].replaceAll(RegExp(r'[^0-9]'), ''));
      _startRestTimer(exerciseId, restTime);
    }
  }

  List<Map<String, dynamic>> _getExercises() {
    return [
      {
        'name': 'Barbell Squats',
        'sets': '4',
        'reps': '8',
        'weights': ['135 lbs', '145 lbs', '155 lbs', '165 lbs'],
        'rest': '90 sec',
        'notes': 'Focus on depth and keeping your chest up',
        'video': 'assets/videos/squat.mp4',
        'completed': 2,
        'isSuperset': false,
      },
      {
        'name': 'Romanian Deadlifts',
        'sets': '3',
        'reps': '12',
        'weights': ['155 lbs', '165 lbs', '175 lbs'],
        'rest': '60 sec',
        'notes': 'Keep a slight bend in your knees, focus on the hamstring stretch',
        'video': 'assets/videos/deadlift.mp4',
        'completed': 0,
        'isSuperset': false,
      },
      {
        'name': 'Leg Press',
        'sets': '3',
        'reps': '15',
        'weights': ['225 lbs', '245 lbs', '265 lbs'],
        'rest': '90 sec',
        'notes': 'Control the eccentric portion, keep feet shoulder-width apart',
        'video': 'assets/videos/legpress.mp4',
        'completed': 0,
        'isSuperset': true,
        'supersetGroup': 'A',
        'supersetOrder': 1,
      },
      {
        'name': 'Leg Extensions',
        'sets': '3',
        'reps': '15',
        'weights': ['70 lbs', '80 lbs', '90 lbs'],
        'rest': '90 sec',
        'notes': 'Focus on squeezing your quads at the top of each rep',
        'video': 'assets/videos/extensions.mp4',
        'completed': 0,
        'isSuperset': true,
        'supersetGroup': 'A',
        'supersetOrder': 2,
      },
      {
        'name': 'Walking Lunges',
        'sets': '3',
        'reps': '12 each',
        'weights': ['25 lbs', '30 lbs', '35 lbs'],
        'rest': '45 sec',
        'notes': 'Take long steps, keep torso upright',
        'video': 'assets/videos/lunges.mp4',
        'completed': 0,
        'isSuperset': false,
      },
    ];
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Check if all exercises are completed
    bool isWorkoutCompleted = _exerciseStates.values.every((exercise) {
      return exercise['completed'] >= int.parse(exercise['sets']);
    });

    return AuthenticatedLayout(
      title: 'Workouts',
      userType: UserType.client,
      selectedNavIndex: 1,
      selectedSubNavIndex: 0,
      subNavItems: _workoutSubNavItems,
      onNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/client/dashboard');
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
          case 6:
            Navigator.pushReplacementNamed(
              context,
              '/profile',
              arguments: UserType.client,
            );
            break;
        }
      },
      onSubNavItemSelected: (index) {
        switch (index) {
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
                stops: const [0.0, 0.85, 1.0],
                colors: [
                  Color(0xff082a30),
                  Color(0xFF111111).withOpacity(0.8),
                  const Color(0xFF1A1A1A),
                ],
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: isWorkoutCompleted ? _buildWorkoutCompletionView() : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWorkoutHeader().animate().fadeIn(duration: 600.ms).slideX(),
                const SizedBox(height: 32),
                _buildWorkoutProgress().animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(),
                const SizedBox(height: 32),
                _buildWorkoutControls().animate().fadeIn(duration: 600.ms, delay: 250.ms).slideX(),
                const SizedBox(height: 32),
                _buildWorkoutExerciseList().animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
      children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lower Body Power',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
            Row(
              children: [
                    _buildWorkoutStat(
                      Icons.fitness_center,
                      '5',
                      'Exercises',
                    ),
                    const SizedBox(width: 24),
                    _buildWorkoutStat(
                      Icons.timer,
                      '45-60',
                      'Minutes',
                    ),
                    const SizedBox(width: 24),
                    _buildWorkoutStat(
                      Icons.local_fire_department,
                      '400-500',
                      'Calories',
                    ),
              ],
            ),
          ],
        ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppTheme.primaryColor,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutProgress() {
    int totalSets = 0;
    int completedSets = 0;
    _exerciseStates.values.forEach((exercise) {
      totalSets += int.parse(exercise['sets']);
      completedSets += exercise['completed'] as int;
    });
    
    int totalExercises = _exerciseStates.length;
    int completedExercises = _exerciseStates.values.where((exercise) {
      return (exercise['completed'] as int) >= int.parse(exercise['sets']);
    }).length;
    
    final progress = totalSets > 0 ? completedSets / totalSets : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A).withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Workout Progress',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.2),
                            AppTheme.primaryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: AppTheme.primaryColor.withOpacity(0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'In Progress',
                            style: TextStyle(
                              color: AppTheme.primaryColor.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '$completedExercises/$totalExercises',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Exercises',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getProgressMessage(completedExercises, totalExercises),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.secondaryColor.withOpacity(0.2),
                                      AppTheme.secondaryColor.withOpacity(0.1),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.secondaryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${(progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: AppTheme.secondaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ).animate(
                                onPlay: (controller) => controller.repeat(),
                              ).shimmer(
                                duration: 2000.ms,
                                color: AppTheme.secondaryColor.withOpacity(0.3),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                height: 8,
                                width: MediaQuery.of(context).size.width * progress,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      AppTheme.secondaryColor,
                                      AppTheme.secondaryColor.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.secondaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate()
                  .scale(
                    duration: 200.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.02, 1.02),
                    curve: Curves.easeInOut,
                  ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.1),
                            AppTheme.primaryColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.2),
                                  AppTheme.primaryColor.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.tips_and_updates,
                              color: AppTheme.primaryColor.withOpacity(0.9),
                              size: 20,
                            ),
                          ).animate(
                            onPlay: (controller) => controller.repeat(),
                          ).shimmer(
                            duration: 2000.ms,
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Focus on maintaining proper form throughout each exercise. Take your time with the warm-up sets to ensure your muscles are properly prepared.',
                              style: TextStyle(
                                color: AppTheme.primaryColor.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate()
                  .scale(
                    duration: 200.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.02, 1.02),
                    curve: Curves.easeInOut,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getProgressMessage(int completed, int total) {
    if (completed == 0) {
      return 'Let\'s get started with your workout!';
    } else if (completed < total / 2) {
      return 'Keep pushing! You\'re making great progress!';
    } else if (completed < total) {
      return 'More than halfway there! Stay strong!';
    } else {
      return 'Amazing job completing all exercises!';
    }
  }

  Widget _buildWorkoutControls() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _completeAllExercises,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(
              'Complete Workout',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.withOpacity(0.2),
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.green.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showResetConfirmationDialog,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Reset Workout',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.red.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isCardView = !_isCardView;
              });
            },
            icon: Icon(_isCardView ? Icons.list : Icons.grid_view, color: Colors.white),
            label: Text(
              _isCardView ? 'List View' : 'Card View',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _completeAllExercises() {
    setState(() {
      // Complete all exercises
      for (final exerciseId in _exerciseStates.keys) {
        final totalSets = int.parse(_exerciseStates[exerciseId]!['sets']);
        _exerciseStates[exerciseId]!['completed'] = totalSets;
      }
      // Set workout as collapsed to show completion view
      _isWorkoutCollapsed = true;
    });
    // Save progress
    _saveProgress();
  }

  Widget _buildWorkoutExerciseList() {
    // Get exercises in their original order
    final orderedExercises = _getExercises();
    
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: orderedExercises.map((exercise) {
        final exerciseId = exercise['name'] as String;
        final exerciseData = _exerciseStates[exerciseId]!;
        
        // If it's part of a superset, check if it's the first exercise in that superset
        if (exercise['isSuperset'] == true) {
          final supersetGroup = exercise['supersetGroup'] as String;
          final supersetOrder = exercise['supersetOrder'] as int;
          
          // Only build superset container for the first exercise in the superset
          if (supersetOrder == 1) {
            // Get all exercises in this superset
            final supersetExercises = orderedExercises
                .where((e) => e['isSuperset'] == true && e['supersetGroup'] == supersetGroup)
                .map((e) => MapEntry<String, Map<String, dynamic>>(
                    e['name'] as String,
                    _exerciseStates[e['name'] as String]!
                ))
                .toList();
            
            return _buildSupersetListGroup(supersetGroup, supersetExercises);
          }
          // Skip other superset exercises as they're handled in the group
          return const SizedBox.shrink();
        }
        
        // Regular exercise
        return _buildExerciseListItem(exerciseId, exerciseData);
      }).toList(),
    );
  }
  
  Widget _buildSupersetListGroup(String groupName, List<MapEntry<String, Map<String, dynamic>>> exercises) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
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
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Superset',
                            style: TextStyle(
                              color: AppTheme.secondaryColor.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Complete one set of each exercise, then rest.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white.withOpacity(0.1),
                height: 1,
              ),
              ...exercises.map((entry) => _buildExerciseListItem(entry.key, entry.value, isInSuperset: true)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseListItem(String exerciseId, Map<String, dynamic> exercise, {bool isInSuperset = false}) {
    final completedSets = exercise['completed'] as int;
    final totalSets = int.parse(exercise['sets']);
    final progress = completedSets / totalSets;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isInSuperset ? 16 : 0,
        vertical: 8,
      ),
      onTap: () => _showExerciseDetails(exerciseId, exercise),
      leading: Container(
        width: 48,
        height: 48,
              decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.fitness_center,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        exercise['name'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          const SizedBox(height: 4),
          Row(
                        children: [
                          Text(
                '${exercise['sets']} sets × ${exercise['reps']}',
                style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                            ),
                          ),
              const SizedBox(width: 16),
                          Text(
                'Rest: ${exercise['rest']}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0 ? AppTheme.secondaryColor : Colors.grey,
                          ),
              minHeight: 4,
              ),
            ),
          ],
                  ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$completedSets/$totalSets',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  void _showExerciseDetails(String exerciseId, Map<String, dynamic> exercise, {double animateFrom = 0.0}) {
    final completedSets = exercise['completed'] as int;
    final totalSets = int.parse(exercise['sets']);
    final isSuperset = exercise['isSuperset'] == true;
    final supersetGroup = isSuperset ? exercise['supersetGroup'] as String? : null;
    final supersetOrder = isSuperset ? exercise['supersetOrder'] as int? : null;

    // Get ordered exercises list
    final orderedExercises = _getOrderedExercises();
    final currentIndex = orderedExercises.indexWhere((e) => e.key == exerciseId);
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < orderedExercises.length - 1;

    void navigateToExercise(String targetExerciseId, Map<String, dynamic> targetExercise, double animationOffset) {
      Navigator.of(context).pop();
      _showExerciseDetails(targetExerciseId, targetExercise, animateFrom: animationOffset);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 400),
      ),
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

            void updateModalState() {
              setModalState(() {});
            }

            void modalCancelRestTimer() {
              _exerciseTimers[exerciseId]?.cancel();
              setState(() {
                _isExerciseResting[exerciseId] = false;
                _remainingRestTimes[exerciseId] = 0;
                _completeSet(exerciseId);
              });
              updateModalState();
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (BuildContext context, ScrollController scrollController) {
                final currentCompletedSets = _exerciseStates[exerciseId]?['completed'] as int;

                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(
                    begin: animateFrom,
                    end: 0.0,
                  ),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(value * MediaQuery.of(context).size.width, 0),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Stack(
        children: [
                        // Main content
                        Column(
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
                            
                            // Exercise header with navigation arrows
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
                                            navigateToExercise(prevExercise.key, prevExercise.value, -1.0);
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
                                            navigateToExercise(nextExercise.key, nextExercise.value, 1.0);
                                          }
                                        : null,
                                    ),
                                  ),
                                  
                                  // Close button
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.close),
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),

                            // Superset indicator (if applicable)
                            if (isSuperset && supersetGroup != null && supersetOrder != null) ...[
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ..._buildSupersetSequence(
                                      orderedExercises,
                                      supersetGroup,
                                      supersetOrder,
                                      exerciseId,
                      ),
                    ],
                  ),
                ),
              ],

                            // Action buttons
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  _buildDetailActionButton(
                                    label: 'Watch Demo',
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
                                    onPressed: () {
                                      // Implement form check functionality
                                    },
                                    isBeta: true,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),
                            
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
                                        exercise['notes'] ?? 'No notes available',
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
                            
                            // Sets progress
                            Expanded(
                              child: ListView(
                                controller: scrollController,
                                padding: const EdgeInsets.all(24),
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
                                      currentCompletedSets,
                                      onSetCompleted: (exerciseId, newCompletedSets) {
                                        if (isSuperset && supersetGroup != null && supersetOrder != null) {
                                          final isLastInSuperset = !_exerciseStates.values.any((e) => 
                                            e['isSuperset'] == true && 
                                            e['supersetGroup'] == supersetGroup && 
                                            e['supersetOrder'] == supersetOrder + 1);

                                          if (!isLastInSuperset) {
                                            // Complete the set immediately for non-last superset exercises
                                            _completeSet(exerciseId);
                                            
                                            // Find and navigate to the next exercise in the superset
                                            final nextExercise = orderedExercises.firstWhere(
                                              (entry) => 
                                                entry.value['isSuperset'] == true && 
                                                entry.value['supersetGroup'] == supersetGroup && 
                                                entry.value['supersetOrder'] == supersetOrder + 1
                                            );
                                            navigateToExercise(nextExercise.key, nextExercise.value, 1.0);
                                          } else {
                                            // Start rest timer for last exercise in superset
                                            _startRestTimer(exerciseId, int.parse(exercise['rest'].replaceAll(RegExp(r'[^0-9]'), '')));
                                            updateModalState();
                                          }
                                        } else {
                                          // Normal rest timer for non-superset exercises
                                          _startRestTimer(exerciseId, int.parse(exercise['rest'].replaceAll(RegExp(r'[^0-9]'), '')));
                                          updateModalState();
                                        }
                                      },
                                      onSkipRest: () => modalCancelRestTimer(),
                        ),
                      ),
                    ],
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
                '${exercise['reps']} reps @ ${weights[setIndex]}',
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

  void _showTrainerNotes(Map<String, dynamic> exercise) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Trainer Notes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
                                        content: Text(
          exercise['notes'] ?? 'No notes available',
          style: const TextStyle(color: Colors.white),
                                        ),
                                        actions: [
                                          TextButton(
                          onPressed: () => Navigator.pop(context),
                                            child: const Text('Close'),
                        ),
                      ],
                    ),
                                    );
                                  }

  void _showCompletionNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetWorkout() {
    // Cancel all active timers
    for (final timer in _exerciseTimers.values) {
      timer?.cancel();
    }
    
    setState(() {
      // Reset exercise states
      _exerciseStates.clear();
      _exerciseTimers.clear();
      _isExerciseResting.clear();
      _remainingRestTimes.clear();
      _isWorkoutCollapsed = false;
      
      // Reinitialize with fresh states
      final exercises = _getExercises();
      for (final exercise in exercises) {
    final exerciseId = exercise['name'];
        _exerciseStates[exerciseId] = {
          ...exercise,
          'completed': 0, // Reset completed sets to 0
        };
        _isExerciseResting[exerciseId] = false;
        _remainingRestTimes[exerciseId] = 0;
      }
    });
    
    // Save the reset state
    _saveProgress();
    
    // Show confirmation message in top right corner
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Workout reset',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 60, // Increased from 20 to 80 to move below breadcrumb
          right: 10,
          bottom: overlay.size.height - 130, // Adjusted from 100 to 160 to maintain proper spacing
          left: overlay.size.width - 220,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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

  void _askCoach(Map<String, dynamic> exercise) {
    // Create exercise context message
    final contextMessage = '''
Exercise: ${exercise['name']}
Sets: ${exercise['sets']} × Reps: ${exercise['reps']}
Weights: ${exercise['weights'].join(', ')}
Notes: ${exercise['notes']}
''';

    // Navigate to messages screen with pre-filled context
    Navigator.pushNamed(
      context,
      '/messages',
      arguments: {
        'userType': UserType.client,
        'prefilledMessage': contextMessage,
      },
    );
  }

  void _askAI(Map<String, dynamic> exercise) {
    final completedSets = exercise['completed'] as int;
    final totalSets = int.parse(exercise['sets']);
    final currentSet = completedSets + 1;
    final weights = exercise['weights'] as List<dynamic>;
    
    // Check if exercise is part of a superset
    final isSuperset = exercise['isSuperset'] == true;
    String? supersetGroup = isSuperset ? exercise['supersetGroup'] as String? : null;
    int? supersetOrder = isSuperset ? exercise['supersetOrder'] as int? : null;
    
    // User Profile Context
    final userContext = '''
User Profile:
• Experience Level: Intermediate
• Training Goal: Strength & Muscle Building
• Age Range: 25-35
• Previous Injuries: None reported
• Preferred Training Style: Progressive Overload
''';

    // Workout Context
    final workoutContext = '''
Workout Context:
• Program: Lower Body Power
• Week 3 of 12-Week Program
• Workout Position: Exercise ${_getExercisePosition(exercise)} of ${_exerciseStates.length}
• Total Volume Target: 12,450 lbs
• Estimated Duration: 45-60 minutes
• Intensity Level: Intermediate
''';

    // Exercise History
    final exerciseHistory = '''
Exercise History:
• Last Performance: 3 days ago
• Previous Weights: 135 lbs (8 reps), 145 lbs (8 reps)
• Personal Best: 165 lbs × 8 reps
• Common Form Notes: Maintain neutral spine, control descent
• Typical Rest Needed: ${exercise['rest']}
''';

    // Physical State Context
    final physicalContext = '''
Current Physical State:
• Energy Level: Fresh (Early in workout)
• Previous Exercise Impact: Minimal
• Recovery Status: Well rested (48h since last leg workout)
• Warm-up Sets Completed: Yes
''';

    // Get current set info
    final currentSetInfo = currentSet <= totalSets
        ? '''
Current Set Details:
• Set $currentSet of ${exercise['sets']}
• Target Weight: ${weights[currentSet - 1]}
• Target Reps: ${exercise['reps']}
• Rest Period: ${exercise['rest']}'''
        : '\nAll sets completed!';

    // Get progress info
    final progressInfo = completedSets > 0
        ? '''
Current Progress:
• Completed Sets: $completedSets
• Weights Used: ${weights.sublist(0, completedSets).join(', ')}
• Performance: Consistent form maintained
• Rest Times: Following ${exercise['rest']} protocol'''
        : '\nNo sets completed yet';

    // Get remaining sets info
    final remainingSets = totalSets - completedSets;
    final remainingInfo = remainingSets > 0
        ? '''
Remaining Work:
• Sets Left: $remainingSets
• Upcoming Weights: ${weights.sublist(completedSets).join(', ')}
• Target Total Volume: ${_calculateTargetVolume(exercise)}'''
        : '';

    // Form and Technique Notes
    final formNotes = '''
Form & Technique Focus:
• Key Points: ${exercise['notes']}
• Common Mistakes to Avoid:
  - Rushing the eccentric phase
  - Losing proper positioning under load
  - Compromising form for weight
• Safety Considerations:
  - Maintain proper bracing
  - Stay within technical capacity
  - Monitor fatigue levels
''';

    // Superset Context (if applicable)
    String supersetContext = '';
    if (isSuperset && supersetGroup != null) {
      // Find all exercises in this superset
      final supersetExercises = _exerciseStates.values
          .where((e) => 
              e['isSuperset'] == true && 
              e['supersetGroup'] == supersetGroup)
          .toList();
      
      // Sort by superset order
      supersetExercises.sort((a, b) => 
          (a['supersetOrder'] as int).compareTo(b['supersetOrder'] as int));
      
      // Build superset exercise list
      final exerciseList = supersetExercises
          .map((e) => '  • ${e['name']} (${e['sets']} × ${e['reps']}, ${e['weights'].join(' → ')})')
          .join('\n');
      
      // Calculate superset progress
      int totalSupersetSets = 0;
      int completedSupersetSets = 0;
      for (final e in supersetExercises) {
        totalSupersetSets += int.parse(e['sets']);
        completedSupersetSets += e['completed'] as int;
      }
      
      // Find current exercise position in superset
      final currentPosition = supersetOrder ?? 0;
      final isFirstInSuperset = currentPosition == 1;
      final isLastInSuperset = currentPosition == supersetExercises.length;
      
      // Get next exercise in superset (if any)
      String nextExerciseInfo = '';
      if (!isLastInSuperset) {
        final nextExercise = supersetExercises.firstWhere(
            (e) => e['supersetOrder'] == currentPosition + 1,
            orElse: () => supersetExercises.first);
        
        nextExerciseInfo = '''
Next Exercise in Superset:
• ${nextExercise['name']}
• Target: ${nextExercise['reps']} reps at ${nextExercise['weights'][completedSets < nextExercise['weights'].length ? completedSets : 0]}
• Key Focus: ${nextExercise['notes']}
''';
      }
      
      // Build complete superset context
      supersetContext = '''
Superset Information:
• Superset Group: $supersetGroup
• Exercise Position: ${currentPosition} of ${supersetExercises.length}
• Superset Progress: $completedSupersetSets/$totalSupersetSets total sets completed
• Rest Strategy: Complete all exercises in sequence before resting

Superset Exercises:
$exerciseList

${nextExerciseInfo}

Superset Training Tips:
• Maintain intensity across all exercises in the superset
• Focus on controlled transitions between exercises
• Manage fatigue to maintain proper form throughout the sequence
• ${isFirstInSuperset ? "Pace yourself as this is the first exercise in the superset" : ""}
• ${isLastInSuperset ? "Take full rest after completing this final exercise in the superset" : "Quickly transition to the next exercise with minimal rest"}
''';
    }

    // Create detailed context
    final detailedContext = '''
$userContext
$workoutContext
${isSuperset ? supersetContext : ""}
$exerciseHistory
$physicalContext
$currentSetInfo
$progressInfo
$remainingInfo
$formNotes
''';

    // Show AI chat dialog with exercise context
    showDialog(
      context: context,
      builder: (BuildContext context) {
          return Dialog(
            backgroundColor: const Color(0xFF2A2A2A),
                          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
              child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                    const Icon(
                      Icons.psychology,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            'Ask AI about ${exercise['name']}${isSuperset ? " (Superset ${supersetGroup})" : ""}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
                          if (currentSet <= totalSets) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Set $currentSet of ${exercise['sets']} - ${weights[currentSet - 1]}',
                              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                    ),
                    const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                          const Text(
                            'Exercise Context:',
                            style: TextStyle(
                                        color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                                      ),
                          ),
                          const SizedBox(height: 8),
                                      Text(
                            detailedContext,
                                        style: const TextStyle(
                              color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ),
                              ),
                              const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: _getSmartPlaceholder(exercise, currentSet, weights, isSuperset),
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                        IconButton(
                      icon: const Icon(Icons.send),
                                          color: AppTheme.primaryColor,
                                onPressed: () {
                        // TODO: Implement send message
                                },
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

  // Helper method to get exercise position in workout
  int _getExercisePosition(Map<String, dynamic> exercise) {
    final exercises = _exerciseStates.values.toList();
    return exercises.indexOf(exercise) + 1;
  }

  // Helper method to calculate target volume for the exercise
  String _calculateTargetVolume(Map<String, dynamic> exercise) {
    final reps = int.parse(exercise['reps'].toString().split(' ')[0]);
    final weights = exercise['weights'] as List<dynamic>;
    final totalVolume = weights.fold<int>(
      0,
      (sum, weight) => sum + (int.parse(weight.toString().split(' ')[0]) * reps),
    );
    return '$totalVolume lbs';
  }

  // Helper method to generate smart placeholder text
  String _getSmartPlaceholder(Map<String, dynamic> exercise, int currentSet, List<dynamic> weights, [bool isSuperset = false]) {
    if (currentSet > int.parse(exercise['sets'])) {
      return isSuperset 
          ? 'Ask about transitioning to the next superset exercise...'
          : 'Ask about recovery or next exercise...';
    }
    
    final isFirstSet = currentSet == 1;
    final isLastSet = currentSet == int.parse(exercise['sets']);
    
    if (isSuperset) {
      if (isFirstSet) {
        return 'Ask about superset technique or pacing strategy...';
      } else if (isLastSet) {
        return 'Ask about completing the superset or managing fatigue...';
      } else {
        return 'Ask about superset set $currentSet (${weights[currentSet - 1]}) or transitions...';
      }
    } else {
      if (isFirstSet) {
        return 'Ask about warm-up or first set technique...';
      } else if (isLastSet) {
        return 'Ask about final set strategy or form check...';
      } else {
        return 'Ask about set $currentSet (${weights[currentSet - 1]}) or rest period...';
      }
    }
  }

  Widget _buildWorkoutCompletionView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated celebration header with enhanced design
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Enhanced trophy icon with glow effect
                            Container(
                              width: 120,
                              height: 120,
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
                                Icons.workspace_premium,
                                color: Colors.white,
                                size: 64,
                              ),
                            ).animate(
                              onPlay: (controller) => controller.repeat(),
                            ).shimmer(
                              duration: 2000.ms,
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              '🎉 Outstanding Work! 🎉',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryColor.withOpacity(0.2),
                                    AppTheme.primaryColor.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: const Text(
                                'Every rep brings you closer to your goals. You\'re building a stronger version of yourself!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // View Summary Button with enhanced design
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.2),
                              AppTheme.primaryColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showWorkoutSummary(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.analytics,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'View Workout Summary',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ).animate()
            .scale(
              duration: 200.ms,
              begin: const Offset(1, 1),
              end: const Offset(1.02, 1.02),
              curve: Curves.easeInOut,
            ),

          const SizedBox(height: 32),

          // Collapsible Recovery Plan Section
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 40 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.all(24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            backgroundColor: Colors.transparent,
                            collapsedBackgroundColor: Colors.transparent,
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryColor.withOpacity(0.2),
                                    AppTheme.primaryColor.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.self_improvement,
                                color: AppTheme.primaryColor,
                                size: 28,
                              ),
                            ).animate(
                              onPlay: (controller) => controller.repeat(),
                            ).shimmer(
                              duration: 2000.ms,
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                            title: const Text(
                              'Recovery Plan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            subtitle: const Text(
                              '5-step personalized plan',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                letterSpacing: -0.3,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryColor.withOpacity(0.2),
                                    AppTheme.primaryColor.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                child: Column(
                                  children: [
                                    _buildRecoveryStepSummary(
                                      step: '1',
                                      title: 'Cool Down',
                                      timing: 'Optional for low/medium intensity',
                                      icon: Icons.directions_walk,
                                      color: AppTheme.primaryColor,
                                    ),
                                    _buildRecoveryStepDivider(),
                                    _buildRecoveryStepSummary(
                                      step: '2',
                                      title: 'Hydration',
                                      timing: 'Replenish lost fluids & electrolytes',
                                      icon: Icons.water_drop,
                                      color: AppTheme.primaryColor,
                                    ),
                                    _buildRecoveryStepDivider(),
                                    _buildRecoveryStepSummary(
                                      step: '3',
                                      title: 'Protein Intake',
                                      timing: 'Promotes muscle growth & repair',
                                      icon: Icons.restaurant,
                                      color: AppTheme.primaryColor,
                                    ),
                                    _buildRecoveryStepDivider(),
                                    _buildRecoveryStepSummary(
                                      step: '4',
                                      title: 'Evening Stretching',
                                      timing: 'Improves flexibility & recovery',
                                      icon: Icons.accessibility_new,
                                      color: AppTheme.primaryColor,
                                    ),
                                    _buildRecoveryStepDivider(),
                                    _buildRecoveryStepSummary(
                                      step: '5',
                                      title: 'Sleep Goal',
                                      timing: '7-9 hours for optimal recovery',
                                      icon: Icons.bedtime,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(height: 24),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppTheme.primaryColor.withOpacity(0.2),
                                                AppTheme.primaryColor.withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppTheme.primaryColor.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () => _showStretchingGuide(context),
                                              borderRadius: BorderRadius.circular(16),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 16,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.primaryColor.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Icon(
                                                        Icons.visibility,
                                                        color: AppTheme.primaryColor,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      'View Full Recovery Plan',
                                                      style: TextStyle(
                                                        color: AppTheme.primaryColor,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      Icons.arrow_forward,
                                                      color: AppTheme.primaryColor,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ).animate()
                                      .scale(
                                        duration: 200.ms,
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.02, 1.02),
                                        curve: Curves.easeInOut,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    String? comparison,
    VoidCallback? onTap,
  }) {
    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
                        color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
                        ),
        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
                          Text(
            title,
                                    style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
                                      fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
              Text(
                value,
                style: const TextStyle(
                            color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                  unit,
                                    style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
            ],
          ),
          if (comparison != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: Colors.green.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  comparison,
                                    style: TextStyle(
                    color: Colors.green.withOpacity(0.8),
                                      fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecoveryStep({
    required String step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
                                  child: Text(
              step,
              style: const TextStyle(
                            color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                description,
                                    style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
        const SizedBox(width: 16),
        Icon(
          icon,
          color: Colors.white.withOpacity(0.3),
          size: 24,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary 
            ? AppTheme.primaryColor 
            : const Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isPrimary 
              ? BorderSide.none
              : BorderSide(
                  color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
        ),
        elevation: isPrimary ? 8 : 0,
        shadowColor: isPrimary 
            ? AppTheme.primaryColor.withOpacity(0.5)
            : Colors.transparent,
      ),
                                  child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
          Icon(
            icon,
            size: 20,
            color: isPrimary 
                ? Colors.white 
                                                : AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
                                            fontWeight: FontWeight.w600,
              color: isPrimary 
                  ? Colors.white 
                  : AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSummary(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
                              return Container(
                                decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              Column(
                children: [
                  // Premium header with animations
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.15),
                                  Colors.transparent,
                                ],
                              ),
                                  border: Border(
                                    bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                    ),
                                  ),
                                ),
                            child: Column(
                              children: [
                                // Handle bar with animation
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Animated trophy icon
                                    TweenAnimationBuilder<double>(
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.elasticOut,
                                      tween: Tween<double>(begin: 0.5, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFFFD700).withOpacity(0.3),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.emoji_events,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Workout Complete',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Lower Body Power',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 16,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Scrollable content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        const SizedBox(height: 24),
                        
                        // Performance Overview with staggered animation
                        ...['Volume', 'Time', 'Intensity', 'Form'].asMap().entries.map(
                          (entry) => TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 800 + (entry.key * 100)),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.05),
                                          Colors.white.withOpacity(0.02),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                  child: Row(
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppTheme.primaryColor.withOpacity(0.2),
                                                AppTheme.primaryColor.withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppTheme.primaryColor.withOpacity(0.3),
                                            ),
                                        ),
                                        child: Icon(
                                            _getMetricIcon(entry.value),
                                            color: AppTheme.primaryColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                      Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.value,
                                          style: TextStyle(
                                                  color: Colors.white.withOpacity(0.7),
                                                  fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    _getMetricValue(entry.value),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _getMetricUnit(entry.value),
                                          style: TextStyle(
                                                      color: Colors.white.withOpacity(0.5),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getMetricColor(entry.value).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _getMetricColor(entry.value).withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getMetricTrendIcon(entry.value),
                                                color: _getMetricColor(entry.value),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _getMetricTrend(entry.value),
                                                style: TextStyle(
                                                  color: _getMetricColor(entry.value),
                                                  fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 32),
                        
                        // Exercise Summary Section with animation
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Exercise Summary',
                                          style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ..._exerciseStates.entries.map((entry) {
                                      final exercise = entry.value;
                                      final completedSets = exercise['completed'] as int;
                                      final totalSets = int.parse(exercise['sets']);
                                      final weights = exercise['weights'] as List<dynamic>;
                                      
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.05),
                                              Colors.white.withOpacity(0.02),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        AppTheme.primaryColor.withOpacity(0.2),
                                                        AppTheme.primaryColor.withOpacity(0.1),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(
                                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.fitness_center,
                                                    color: AppTheme.primaryColor,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                      Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        exercise['name'],
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${exercise['sets']} × ${exercise['reps']}',
                                                        style: TextStyle(
                                                          color: Colors.white.withOpacity(0.7),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.secondaryColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: AppTheme.secondaryColor.withOpacity(0.3),
                                                    ),
                                                  ),
                                        child: Text(
                                                    '$completedSets/$totalSets',
                                                    style: const TextStyle(
                                                      color: AppTheme.secondaryColor,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.1),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Set Progression',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                                      fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      ...List.generate(weights.length, (index) {
                                                        final isLast = index == weights.length - 1;
                                                        return Expanded(
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 12,
                                                                    vertical: 8,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    color: const Color(0xFF2A2A2A),
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    border: Border.all(
                                                                      color: Colors.white.withOpacity(0.1),
                                                                    ),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        weights[index].toString(),
                                                                        style: const TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 16,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(height: 4),
                                                                      Text(
                                                                        'Set ${index + 1}',
                                                                        style: TextStyle(
                                                                          color: Colors.white.withOpacity(0.5),
                                                                          fontSize: 12,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              if (!isLast)
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                  child: Icon(
                                                                    Icons.arrow_forward,
                                                                    color: Colors.white.withOpacity(0.3),
                                                                    size: 14,
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                    ],
                                                  ),
                                                  if (weights.length > 1) ...[
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.trending_up,
                                                          color: AppTheme.secondaryColor.withOpacity(0.7),
                                                          size: 14,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${((int.parse(weights.last.toString().replaceAll(RegExp(r'[^0-9]'), '')) - int.parse(weights.first.toString().replaceAll(RegExp(r'[^0-9]'), ''))) / int.parse(weights.first.toString().replaceAll(RegExp(r'[^0-9]'), '')) * 100).toStringAsFixed(1)}% increase',
                                                          style: TextStyle(
                                                            color: AppTheme.secondaryColor.withOpacity(0.7),
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 32),
                        
                        // Share section with animation
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 40 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primaryColor.withOpacity(0.15),
                                        AppTheme.primaryColor.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Share Your Achievement',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildShareOption(
                                            icon: Icons.photo_camera,
                                            label: 'Story',
                                            onTap: () {},
                                          ),
                                          _buildShareOption(
                                            icon: Icons.share,
                                            label: 'Share',
                                            onTap: () {},
                                          ),
                                          _buildShareOption(
                                            icon: Icons.save_alt,
                                            label: 'Save',
                                            onTap: () {},
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getMetricIcon(String metric) {
    switch (metric) {
      case 'Volume':
        return Icons.fitness_center;
      case 'Time':
        return Icons.timer;
      case 'Intensity':
        return Icons.local_fire_department;
      case 'Form':
        return Icons.psychology;
      default:
        return Icons.analytics;
    }
  }

  String _getMetricValue(String metric) {
    switch (metric) {
      case 'Volume':
        return '12,450';
      case 'Time':
        return '52';
      case 'Intensity':
        return '8.5';
      case 'Form':
        return '92';
      default:
        return '0';
    }
  }

  String _getMetricUnit(String metric) {
    switch (metric) {
      case 'Volume':
        return 'lbs';
      case 'Time':
        return 'min';
      case 'Intensity':
        return '/10';
      case 'Form':
        return '%';
      default:
        return '';
    }
  }

  Color _getMetricColor(String metric) {
    final trend = _getMetricTrend(metric);
    if (trend.startsWith('-')) {
      return const Color(0xFFE53935); // Red for negative trends
    } else if (trend.startsWith('+')) {
      return const Color(0xFF4CAF50); // Green for positive trends
    } else {
      return Colors.grey; // Neutral for no change
    }
  }

  IconData _getMetricTrendIcon(String metric) {
    switch (metric) {
      case 'Time':
        return Icons.trending_down;
      default:
        return Icons.trending_up;
    }
  }

  String _getMetricTrend(String metric) {
    switch (metric) {
      case 'Volume':
        return '+15%';
      case 'Time':
        return '-5 min';
      case 'Intensity':
        return '+0.5';
      case 'Form':
        return '+3%';
      default:
        return '';
    }
  }

  Widget _buildWeightProgressItem({
    required String label,
    required String weight,
    bool isHighlighted = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          weight,
          style: TextStyle(
            color: isHighlighted ? AppTheme.secondaryColor : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
                                  style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
                                      ),
                                    );
                                  }

  void _showWhyInfo(BuildContext context, List<String> reasons, String title) {
    showGeneralDialog(
                                      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8 * animation.value,
            sigmaY: 8 * animation.value,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
            child: FadeTransition(
              opacity: animation,
              child: AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: EdgeInsets.zero,
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Premium gradient header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.15),
                              Colors.black.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Animated icon container
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutBack,
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.primaryColor.withOpacity(0.2),
                                          AppTheme.primaryColor.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.2),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.psychology,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            // Title with animation
                                      Expanded(
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutQuart,
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(20 * (1 - value), 0),
                                        child: Text(
                                        'Why $title?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                  );
                                },
                              ),
                            ),
                            // Close button with hover effect
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Reasons list with staggered animation
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              reasons.length,
                              (index) => TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 600 + (index * 100)),
                                curve: Curves.easeOutQuart,
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.05),
                                              Colors.white.withOpacity(0.02),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(top: 4),
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    AppTheme.primaryColor,
                                                    AppTheme.primaryColor.withOpacity(0.7),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(4),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                                reasons[index],
                                          style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                                                  fontSize: 16,
                                                  height: 1.5,
                                                  letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                            ),
                          ),
                        ),
                      ),
                      // Bottom gradient fade
                    Container(
                        height: 40,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF1E1E1E).withOpacity(0),
                              const Color(0xFF1E1E1E),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildRecoveryStepSummary({
    required String step,
    required String title,
    required String timing,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      step,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(),
                ).shimmer(
                  duration: 2000.ms,
                  color: color.withOpacity(0.3),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timing,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color.withOpacity(0.8),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .scale(
        duration: 200.ms,
        begin: const Offset(1, 1),
        end: const Offset(1.02, 1.02),
        curve: Curves.easeInOut,
      );
  }

  Widget _buildRecoveryStepDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  void _showStretchingGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF1A1A1A),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    _buildRecoveryGuideHeader(),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          ...recoveryData.map((section) {
                            final items = section['exercises'] ?? section['recommendations'] ?? [];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Header with collapsible info
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  section['title'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        AppTheme.primaryColor.withOpacity(0.2),
                                                        AppTheme.primaryColor.withOpacity(0.1),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    section['timing'],
                                                    style: TextStyle(
                                                      color: AppTheme.primaryColor.withOpacity(0.9),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Collapsible "Why This Matters" section
                                      Theme(
                                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    AppTheme.primaryColor.withOpacity(0.1),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                                ),
                                              ),
                                              child: ExpansionTile(
                                                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                collapsedShape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                backgroundColor: Colors.transparent,
                                                collapsedBackgroundColor: Colors.transparent,
                                                title: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                          colors: [
                                                            AppTheme.primaryColor.withOpacity(0.2),
                                                            AppTheme.primaryColor.withOpacity(0.1),
                                                          ],
                                                        ),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(
                                                          color: AppTheme.primaryColor.withOpacity(0.3),
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.info_outline,
                                                        color: AppTheme.primaryColor.withOpacity(0.9),
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      'Why This Matters',
                                                      style: TextStyle(
                                                        color: AppTheme.primaryColor.withOpacity(0.9),
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        ...List<String>.from(section['why']).map((reason) => Padding(
                                                          padding: const EdgeInsets.only(bottom: 8),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                margin: const EdgeInsets.only(top: 6),
                                                                width: 6,
                                                                height: 6,
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    begin: Alignment.topLeft,
                                                                    end: Alignment.bottomRight,
                                                                    colors: [
                                                                      AppTheme.primaryColor,
                                                                      AppTheme.primaryColor.withOpacity(0.7),
                                                                    ],
                                                                  ),
                                                                  borderRadius: BorderRadius.circular(3),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                                                      blurRadius: 4,
                                                                      spreadRadius: 1,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(width: 12),
                                                              Expanded(
                                                                child: Text(
                                                                  reason,
                                                                  style: TextStyle(
                                                                    color: Colors.white.withOpacity(0.9),
                                                                    fontSize: 14,
                                                                    height: 1.5,
                                                                    letterSpacing: 0.2,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )).toList(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Section Note - Removed
                                _buildRecoveryGuideExerciseList(items),
                                const SizedBox(height: 24),
                              ],
                            ).animate()
                              .fadeIn(duration: 400.ms)
                              .slideX(
                                begin: 0.2,
                                curve: Curves.easeOutCubic,
                              );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecoveryGuideHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.2),
                          AppTheme.primaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.self_improvement,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  ).shimmer(
                    duration: 2000.ms,
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Full Recovery Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Info section below the header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.2),
                            AppTheme.primaryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Follow this personalized plan to maximize your recovery and prepare for your next workout.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLedIconContainer({
    required IconData icon,
    required double size,
    required double padding,
  }) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(padding + 4),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
      child: Icon(
        icon,
        color: AppTheme.primaryColor,
        size: size,
      ),
    );
  }

  Widget _buildLedButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (states) => states.contains(MaterialState.pressed)
              ? AppTheme.primaryColor.withOpacity(0.2)
              : null,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
                ),
                const SizedBox(width: 8),
                Text(
              label,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                        fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildRecoveryStepNumber(String number) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Update the exercise execution step numbers
  Widget _buildExecutionStepNumber(int number) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // Update the tips icon container
  Widget _buildTipsIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.tips_and_updates,
        color: AppTheme.secondaryColor,
        size: 20,
      ),
    );
  }

  // Use these new widgets in your existing methods
  Widget _buildRecoveryGuideExerciseList(List<dynamic> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        final bool isCoolDown = item['name']?.contains('Walking') == true || item['name']?.contains('Cycling') == true;
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Exercise Icon with Animation
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryColor.withOpacity(0.2),
                                AppTheme.primaryColor.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            item['icon'],
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ).animate(
                          onPlay: (controller) => controller.repeat(),
                        ).shimmer(
                          duration: 2000.ms,
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.primaryColor.withOpacity(0.2),
                                          AppTheme.primaryColor.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          color: AppTheme.primaryColor.withOpacity(0.9),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${item['duration'] ?? item['timing'] ?? ''} ${item['sets'] ?? ''}',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor.withOpacity(0.9),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isCoolDown && (item['muscle'] != null || item['intensity'] != null)) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppTheme.secondaryColor.withOpacity(0.2),
                                            AppTheme.secondaryColor.withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.secondaryColor.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.fitness_center,
                                            color: AppTheme.secondaryColor.withOpacity(0.9),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            item['muscle'] ?? item['intensity'] ?? '',
                                            style: TextStyle(
                                              color: AppTheme.secondaryColor.withOpacity(0.9),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Description
                  if (item['description'] != null || item['details'] != null)
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Text(
                        item['description'] ?? item['details'] ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                  // Execution Steps
                  if (item['execution'] != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
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
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryColor.withOpacity(0.2),
                                      AppTheme.primaryColor.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(
                                  Icons.format_list_numbered,
                                  color: AppTheme.primaryColor.withOpacity(0.9),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Execution Steps',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(
                            (item['execution'] as List).length,
                            (stepIndex) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.primaryColor.withOpacity(0.2),
                                          AppTheme.primaryColor.withOpacity(0.1),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (stepIndex + 1).toString(),
                                        style: TextStyle(
                                          color: AppTheme.primaryColor.withOpacity(0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['execution'][stepIndex],
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Pro Tips Section
                  if (!isCoolDown && item['tips'] != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.secondaryColor.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.secondaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.secondaryColor.withOpacity(0.2),
                                        AppTheme.secondaryColor.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.secondaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.tips_and_updates,
                                    color: AppTheme.secondaryColor,
                                    size: 20,
                                  ),
                                ).animate(
                                  onPlay: (controller) => controller.repeat(),
                                ).shimmer(
                                  duration: 2000.ms,
                                  color: AppTheme.secondaryColor.withOpacity(0.3),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pro Tip',
                                        style: TextStyle(
                                          color: AppTheme.secondaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['tips'],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 15,
                                          height: 1.5,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .scale(
            duration: 200.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.02, 1.02),
            curve: Curves.easeInOut,
          );
      },
    );
  }

  // Add this helper method to get exercises in the correct order
  List<MapEntry<String, Map<String, dynamic>>> _getOrderedExercises() {
    final exercises = _exerciseStates.entries.toList();
    
    // Sort exercises based on their order in the workout
    exercises.sort((a, b) {
      // First, handle superset ordering
      final aIsSuperset = a.value['isSuperset'] == true;
      final bIsSuperset = b.value['isSuperset'] == true;
      
      if (aIsSuperset && bIsSuperset) {
        // If both are supersets, compare their groups first
        final aGroup = a.value['supersetGroup'] as String;
        final bGroup = b.value['supersetGroup'] as String;
        
        if (aGroup == bGroup) {
          // If same group, sort by supersetOrder
          return (a.value['supersetOrder'] as int).compareTo(b.value['supersetOrder'] as int);
        }
        return aGroup.compareTo(bGroup);
      }
      
      // If only one is a superset, maintain original order
      if (aIsSuperset != bIsSuperset) {
        return exercises.indexOf(a).compareTo(exercises.indexOf(b));
      }
      
      // For non-superset exercises, maintain original order
      return exercises.indexOf(a).compareTo(exercises.indexOf(b));
    });
    
    return exercises;
  }

  List<Widget> _buildSupersetSequence(
    List<MapEntry<String, Map<String, dynamic>>> allExercises,
    String supersetGroup,
    int currentOrder,
    String currentExerciseId,
  ) {
    // Get all exercises in this superset
    final supersetExercises = allExercises
        .where((entry) => 
          entry.value['isSuperset'] == true && 
          entry.value['supersetGroup'] == supersetGroup)
        .toList()
        ..sort((a, b) => (a.value['supersetOrder'] as int)
            .compareTo(b.value['supersetOrder'] as int));

    List<Widget> sequence = [];
    
    for (int i = 0; i < supersetExercises.length; i++) {
      final exercise = supersetExercises[i];
      final isCurrentExercise = exercise.key == currentExerciseId;
      
      // Add exercise indicator
      sequence.add(
        GestureDetector(
          onTap: isCurrentExercise ? null : () {
            Navigator.pop(context);
            _showExerciseDetails(exercise.key, exercise.value);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrentExercise 
                ? AppTheme.secondaryColor.withOpacity(0.2)
                : Colors.transparent,
              border: Border.all(
                color: isCurrentExercise 
                  ? AppTheme.secondaryColor
                  : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCurrentExercise)
                const Icon(
                    Icons.sync_alt,
                    size: 16,
                    color: AppTheme.secondaryColor,
                ),
                if (isCurrentExercise)
                const SizedBox(width: 8),
                Text(
                  exercise.value['name'],
                  style: TextStyle(
                    color: isCurrentExercise 
                      ? AppTheme.secondaryColor
                      : Colors.white.withOpacity(0.7),
                    fontWeight: isCurrentExercise 
                      ? FontWeight.bold
                      : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      
      // Add arrow between exercises
      if (i < supersetExercises.length - 1) {
        sequence.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward,
              size: 16,
              color: Colors.white.withOpacity(0.5),
            ),
      ),
    );
  }
} 
    
    return sequence;
  }

  void _showWorkoutSummary(BuildContext context) {
    final workoutStats = {
      'volume': {
        'value': '12,450',
        'unit': 'lbs',
        'change': '+15%',
        'icon': Icons.fitness_center,
        'color': const Color(0xFF5856D6),
      },
      'duration': {
        'value': '52',
        'unit': 'min',
        'change': '-5 min',
        'icon': Icons.timer,
        'color': const Color(0xFF30D158),
      },
      'intensity': {
        'value': '8.5',
        'unit': '/10',
        'change': '+0.5',
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFFF9F0A),
      },
      'form': {
        'value': '92',
        'unit': '%',
        'change': '+3%',
        'icon': Icons.psychology,
        'color': const Color(0xFF64D2FF),
      },
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildWorkoutSummary(context),
    );
  }

  Widget _buildMetricTrend(String metric) {
    final trend = _getMetricTrend(metric);
    final isPositive = !trend.startsWith('-');
    final color = isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935); // Green for positive, Red for negative
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            trend,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String metric, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildMetricTrend(metric),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
// ... rest of existing code ...
} // End of _WorkoutsScreenState class

