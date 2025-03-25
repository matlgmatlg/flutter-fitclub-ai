import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this for HapticFeedback
import '../../core/user_type.dart';
import '../../core/theme.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/breadcrumb_navigation.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_animations/simple_animations.dart';

class UpcomingWorkoutsScreen extends StatefulWidget {
  const UpcomingWorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<UpcomingWorkoutsScreen> createState() => _UpcomingWorkoutsScreenState();
}

class _UpcomingWorkoutsScreenState extends State<UpcomingWorkoutsScreen> {
  int _selectedNavIndex = 1; // Workouts tab
  Set<String> _selectedTypeFilters = {}; // Track multiple selected filters
  String _selectedTimeFilter = 'All Workouts';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Calendar state
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate = DateTime.now();
  bool _isCalendarExpanded = false;
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _workoutsListController = ScrollController();
  final Map<String, GlobalKey> _workoutKeys = {};
  
  // Sample upcoming workouts data
  final List<Map<String, dynamic>> _upcomingWorkouts = [
    {
      'id': 'w1',
      'title': 'Full Body Strength',
      'trainer': 'Alex Johnson',
      'date': DateTime.now().add(const Duration(days: 1)),
      'duration': '45 min',
      'difficulty': 'Intermediate',
      'focus': 'Strength',
      'exercises': 8,
      'muscleGroups': ['Chest', 'Back', 'Legs', 'Shoulders'],
      'calories': 450,
    },
    {
      'id': 'w2',
      'title': 'HIIT Cardio Blast',
      'trainer': 'Sarah Miller',
      'date': DateTime.now().add(const Duration(days: 3)),
      'duration': '30 min',
      'difficulty': 'Advanced',
      'focus': 'Cardio',
      'exercises': 12,
      'muscleGroups': ['Full Body'],
      'calories': 400,
    },
    {
      'id': 'w3',
      'title': 'Yoga Flow',
      'trainer': 'Emma Davis',
      'date': DateTime.now().add(const Duration(days: 4)),
      'duration': '40 min',
      'difficulty': 'Beginner',
      'focus': 'Flexibility',
      'exercises': 15,
      'muscleGroups': ['Full Body', 'Core'],
      'calories': 200,
    },
    {
      'id': 'w4',
      'title': 'Upper Body Power',
      'trainer': 'Alex Johnson',
      'date': DateTime.now().add(const Duration(days: 7)),
      'duration': '50 min',
      'difficulty': 'Intermediate',
      'focus': 'Strength',
      'exercises': 10,
      'muscleGroups': ['Chest', 'Shoulders', 'Triceps', 'Back'],
      'calories': 380,
    },
    {
      'id': 'w5',
      'title': 'Core & Flexibility',
      'trainer': 'Mike Thompson',
      'date': DateTime.now().add(const Duration(days: 8)),
      'duration': '35 min',
      'difficulty': 'Intermediate',
      'focus': 'Flexibility',
      'exercises': 12,
      'muscleGroups': ['Core', 'Lower Back', 'Hips'],
      'calories': 250,
    },
    {
      'id': 'w6',
      'title': 'Endurance Run',
      'trainer': 'Sarah Miller',
      'date': DateTime.now().add(const Duration(days: 10)),
      'duration': '45 min',
      'difficulty': 'Advanced',
      'focus': 'Cardio',
      'exercises': 8,
      'muscleGroups': ['Legs', 'Core'],
      'calories': 500,
    },
    {
      'id': 'w7',
      'title': 'Lower Body Focus',
      'trainer': 'Alex Johnson',
      'date': DateTime.now().add(const Duration(days: 14)),
      'duration': '55 min',
      'difficulty': 'Advanced',
      'focus': 'Strength',
      'exercises': 9,
      'muscleGroups': ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
      'calories': 420,
    },
    {
      'id': 'w8',
      'title': 'Morning Yoga',
      'trainer': 'Emma Davis',
      'date': DateTime.now().add(const Duration(days: 15)),
      'duration': '30 min',
      'difficulty': 'Beginner',
      'focus': 'Flexibility',
      'exercises': 12,
      'muscleGroups': ['Full Body', 'Core', 'Balance'],
      'calories': 180,
    },
    {
      'id': 'w9',
      'title': 'HIIT & Core',
      'trainer': 'Sarah Miller',
      'date': DateTime.now().add(const Duration(days: 17)),
      'duration': '40 min',
      'difficulty': 'Advanced',
      'focus': 'Cardio',
      'exercises': 15,
      'muscleGroups': ['Core', 'Full Body'],
      'calories': 450,
    },
    {
      'id': 'w10',
      'title': 'Push Day',
      'trainer': 'Alex Johnson',
      'date': DateTime.now().add(const Duration(days: 21)),
      'duration': '50 min',
      'difficulty': 'Intermediate',
      'focus': 'Strength',
      'exercises': 8,
      'muscleGroups': ['Chest', 'Shoulders', 'Triceps'],
      'calories': 400,
    },
    {
      'id': 'w11',
      'title': 'Recovery Flow',
      'trainer': 'Emma Davis',
      'date': DateTime.now().add(const Duration(days: 22)),
      'duration': '45 min',
      'difficulty': 'Beginner',
      'focus': 'Flexibility',
      'exercises': 14,
      'muscleGroups': ['Full Body', 'Mobility'],
      'calories': 220,
    },
    {
      'id': 'w12',
      'title': 'Tabata Training',
      'trainer': 'Sarah Miller',
      'date': DateTime.now().add(const Duration(days: 24)),
      'duration': '35 min',
      'difficulty': 'Advanced',
      'focus': 'Cardio',
      'exercises': 16,
      'muscleGroups': ['Full Body'],
      'calories': 380,
    },
    {
      'id': 'w13',
      'title': 'Pull Day',
      'trainer': 'Alex Johnson',
      'date': DateTime.now().add(const Duration(days: 28)),
      'duration': '50 min',
      'difficulty': 'Intermediate',
      'focus': 'Strength',
      'exercises': 9,
      'muscleGroups': ['Back', 'Biceps', 'Rear Deltoids'],
      'calories': 390,
    },
    {
      'id': 'w14',
      'title': 'Power Yoga',
      'trainer': 'Emma Davis',
      'date': DateTime.now().add(const Duration(days: 29)),
      'duration': '40 min',
      'difficulty': 'Intermediate',
      'focus': 'Flexibility',
      'exercises': 18,
      'muscleGroups': ['Full Body', 'Core', 'Balance'],
      'calories': 280,
    },
    {
      'id': 'w15',
      'title': 'Sprint Intervals',
      'trainer': 'Sarah Miller',
      'date': DateTime.now().add(const Duration(days: 31)),
      'duration': '30 min',
      'difficulty': 'Advanced',
      'focus': 'Cardio',
      'exercises': 10,
      'muscleGroups': ['Legs', 'Core'],
      'calories': 450,
    },
  ];

  List<Map<String, dynamic>> get _filteredWorkouts {
    List<Map<String, dynamic>> filtered = List.from(_upcomingWorkouts);
    
    // Apply type filters
    if (_selectedTypeFilters.isNotEmpty) {
      filtered = filtered.where((workout) {
        return _selectedTypeFilters.contains(workout['focus']);
      }).toList();
    }
    
    // Apply time filter
    if (_selectedTimeFilter == 'This Week') {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      filtered = filtered.where((workout) {
        final workoutDate = workout['date'] as DateTime;
        return workoutDate.isAfter(weekStart) && workoutDate.isBefore(weekEnd);
      }).toList();
    } else if (_selectedTimeFilter == 'This Month') {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);
      filtered = filtered.where((workout) {
        final workoutDate = workout['date'] as DateTime;
        return workoutDate.isAfter(monthStart) && workoutDate.isBefore(monthEnd);
      }).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((workout) {
        // Search in title, trainer, and focus
        final basicMatch = workout['title'].toString().toLowerCase().contains(query) ||
               workout['trainer'].toString().toLowerCase().contains(query) ||
               workout['focus'].toString().toLowerCase().contains(query);
        
        // Search in difficulty level
        final difficultyMatch = workout['difficulty'].toString().toLowerCase().contains(query);
        
        // Search in duration
        final durationMatch = workout['duration'].toString().toLowerCase().contains(query);
        
        // Search in number of exercises
        final exercisesMatch = '${workout['exercises']} exercises'.toLowerCase().contains(query);
        
        // Search in calories
        final calories = workout['calories'] ?? 350;
        final caloriesMatch = '$calories kcal'.toLowerCase().contains(query) ||
                            '$calories calories'.toLowerCase().contains(query);
        
        // Search in muscle groups
        final muscleGroups = (workout['muscleGroups'] as List<String>? ?? ['Chest', 'Shoulders', 'Triceps']);
        final muscleGroupMatch = muscleGroups.any((muscle) => 
          muscle.toLowerCase().contains(query));
        
        // Search in descriptive terms
        final descriptiveMatch = query == 'advanced' && workout['difficulty'] == 'Advanced' ||
                               query == 'beginner' && workout['difficulty'] == 'Beginner' ||
                               query == 'intermediate' && workout['difficulty'] == 'Intermediate' ||
                               query == 'short' && workout['duration'].toString().contains('30') ||
                               query == 'long' && (workout['duration'].toString().contains('45') || 
                                                 workout['duration'].toString().contains('50')) ||
                               query == 'quick' && workout['duration'].toString().contains('30') ||
                               query == 'intense' && workout['difficulty'] == 'Advanced';
        
        return basicMatch || difficultyMatch || durationMatch || exercisesMatch || 
               caloriesMatch || muscleGroupMatch || descriptiveMatch;
      }).toList();
    }
    
    return filtered;
  }

  void _handleTimeFilterTap(String filter) {
    setState(() {
      _selectedTimeFilter = filter;
    });
    HapticFeedback.lightImpact();
  }

  void _handleTypeFilterTap(String filter) {
    setState(() {
      if (_selectedTypeFilters.contains(filter)) {
        _selectedTypeFilters.remove(filter);
      } else {
        _selectedTypeFilters.add(filter);
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    // Initialize workout keys for scrolling
    for (final workout in _upcomingWorkouts) {
      _workoutKeys[workout['id']] = GlobalKey();
    }
    // Calculate visible days after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateVisibleDays();
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    final now = DateTime.now();
    final dayIndex = now.day - 1;
    if (_calendarScrollController.hasClients) {
      _calendarScrollController.animateTo(
        dayIndex * 72.0, // 60 (width) + 12 (padding)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _workoutsListController.dispose();
    super.dispose();
  }

  // Get workouts for a specific date
  List<Map<String, dynamic>> _getWorkoutsForDate(DateTime date) {
    return _upcomingWorkouts.where((workout) {
      final workoutDate = workout['date'] as DateTime;
      return workoutDate.year == date.year &&
             workoutDate.month == date.month &&
             workoutDate.day == date.day;
    }).toList();
  }

  // Scroll to specific workout
  void _scrollToWorkout(String workoutId) {
    final workoutKey = _workoutKeys[workoutId];
    if (workoutKey?.currentContext != null) {
      Scrollable.ensureVisible(
        workoutKey!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Workouts',
      userType: UserType.client,
      selectedNavIndex: _selectedNavIndex,
      selectedSubNavIndex: 1, // Upcoming workouts tab
      subNavItems: _workoutSubNavItems,
      onNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/client/dashboard');
            break;
          case 1: // Workouts menu
            Navigator.pushReplacementNamed(context, '/client/workouts'); // Direct to today's workout
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
          case 0: // Today's Workout
            Navigator.pushReplacementNamed(context, '/client/workouts');
            break;
          case 1: // Upcoming Workouts
            Navigator.pushReplacementNamed(context, '/client/upcoming-workouts');
            break;
          case 2: // Workout History
            Navigator.pushReplacementNamed(context, '/client/workout-history');
            break;
          case 3: // My Gym
            Navigator.pushReplacementNamed(context, '/client/my-gym');
            break;
        }
      },
      child: _buildContent(),
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

  Widget _buildContent() {
    return Stack(
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
        // Content
        LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;
            
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: isWideScreen
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildHeader().animate().fadeIn(duration: 600.ms).slideX(),
                                const SizedBox(height: 24),
                                _buildCalendarSection().animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(),
                                const SizedBox(height: 24),
                                _buildWorkoutsList().animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildQuickFilters(),
                                const SizedBox(height: 24),
                                _buildWorkoutInsights(),
                                const SizedBox(height: 24),
                                _buildWorkoutSuggestions(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildHeader().animate().fadeIn(duration: 600.ms).slideX(),
                          const SizedBox(height: 24),
                          _buildCalendarSection().animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(),
                          const SizedBox(height: 24),
                          _buildQuickFilters(),
                          const SizedBox(height: 24),
                          _buildWorkoutsList().animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(),
                          const SizedBox(height: 24),
                          _buildWorkoutInsights(),
                          const SizedBox(height: 24),
                          _buildWorkoutSuggestions(),
                        ],
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGlassmorphicContainer({
    required Widget child,
    Color? backgroundColor,
    double blur = 10,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _buildGlassmorphicContainer(
      backgroundColor: Colors.white.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Workouts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildQuickActionButtons(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Plan and track your fitness journey',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          'Add to Calendar',
          Icons.calendar_today_rounded,
          AppTheme.primaryColor,
          onTap: () {
            // Add calendar integration
          },
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          'Share Schedule',
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
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).shimmer(
          duration: 2000.ms,
          color: color.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    final now = DateTime.now();
    final dateFormat = DateFormat('E'); // Day of week abbreviation
    final dayFormat = DateFormat('d'); // Day of month
    final monthFormat = DateFormat('MMMM yyyy'); // Month and year

    return _buildGlassmorphicContainer(
      backgroundColor: Colors.white.withOpacity(0.05),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            // Calendar Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            monthFormat.format(_selectedMonth),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_getWorkoutsForMonth(_selectedMonth).length} workouts this month',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMonth = DateTime.now();
                            _selectedDate = DateTime.now();
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Today',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalendarActionButton(
                        'Previous Month',
                        Icons.chevron_left_rounded,
                        onTap: () {
                          setState(() {
                            _selectedMonth = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month - 1,
                            );
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildCalendarActionButton(
                        'Next Month',
                        Icons.chevron_right_rounded,
                        onTap: () {
                          setState(() {
                            _selectedMonth = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month + 1,
                            );
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildCalendarActionButton(
                        _isCalendarExpanded ? 'Collapse Calendar' : 'Expand Calendar',
                        _isCalendarExpanded ? Icons.unfold_less : Icons.unfold_more,
                        onTap: () {
                          setState(() {
                            _isCalendarExpanded = !_isCalendarExpanded;
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Show either expanded calendar or collapsed strip based on state
            if (_isCalendarExpanded)
              _buildExpandedCalendarView()
            else
              _buildCollapsedCalendarStrip(),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedCalendarStrip() {
    final now = DateTime.now();
    final dateFormat = DateFormat('E');
    final dayFormat = DateFormat('d');
    
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ListView.builder(
        controller: _calendarScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 365, // Show a full year of dates
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index - now.day + 1));
          final workouts = _getWorkoutsForDate(date);
          final hasWorkout = workouts.isNotEmpty;
          final isToday = date.year == now.year &&
                         date.month == now.month &&
                         date.day == now.day;
          final isSelected = _selectedDate?.year == date.year &&
                           _selectedDate?.month == date.month &&
                           _selectedDate?.day == date.day;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                  _selectedMonth = DateTime(date.year, date.month);
                });
                HapticFeedback.lightImpact();
                if (hasWorkout) {
                  _showWorkoutPreviewSheet(context, workouts);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 108,
                decoration: BoxDecoration(
                  color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : (hasWorkout 
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday
                      ? AppTheme.primaryColor
                      : Colors.white.withOpacity(0.1),
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateFormat.format(date),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayFormat.format(date),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                          ? AppTheme.primaryColor
                          : (isToday 
                              ? AppTheme.primaryColor
                              : Colors.white),
                      ),
                    ),
                    if (hasWorkout) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor,
                        ),
                      ).animate(
                        onPlay: (controller) => controller.repeat(),
                      ).shimmer(
                        duration: 2000.ms,
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ).animate()
            .fadeIn(
              duration: 400.ms,
              delay: Duration(milliseconds: 50 * index),
            )
            .slideX(
              begin: 0.2,
              end: 0,
              duration: 400.ms,
              delay: Duration(milliseconds: 50 * index),
              curve: Curves.easeOutCubic,
            );
        },
      ),
    );
  }

  // Helper method to get workouts for a month
  List<Map<String, dynamic>> _getWorkoutsForMonth(DateTime month) {
    return _upcomingWorkouts.where((workout) {
      final workoutDate = workout['date'] as DateTime;
      return workoutDate.year == month.year && workoutDate.month == month.month;
    }).toList();
  }

  // Helper method to get days in month
  int _getDaysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  void _showWorkoutPreviewSheet(BuildContext context, List<Map<String, dynamic>> workouts) {
    final dateFormat = DateFormat('EEEE, MMMM d');
    final timeFormat = DateFormat('h:mm a');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildGlassmorphicContainer(
        backgroundColor: const Color(0xFF2A2A2A).withOpacity(0.95),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                // Drag handle and date header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
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
                                  dateFormat.format(_selectedDate!),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${workouts.length} workout${workouts.length > 1 ? 's' : ''} scheduled',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
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
                const SizedBox(height: 24),
                const Divider(height: 1, color: Colors.white12),
                const SizedBox(height: 24),
                // Workouts list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildWorkoutPreviewCard(
                        workouts[index],
                        isLast: index == workouts.length - 1,
                      ).animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: Duration(milliseconds: 100 * index),
                        )
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 400.ms,
                          delay: Duration(milliseconds: 100 * index),
                          curve: Curves.easeOutCubic,
                        ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutPreviewCard(Map<String, dynamic> workout, {bool isLast = false}) {
    final dateFormat = DateFormat('EEEE, MMMM d');
    final timeFormat = DateFormat('h:mm a');
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildWorkoutTypeIcon(workout['focus']),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          workout['trainer'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          timeFormat.format(workout['date']),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildWorkoutStat(
                Icons.timer_rounded,
                workout['duration'],
                'Duration',
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildWorkoutStat(
                Icons.fitness_center_rounded,
                '${workout['exercises']} exercises',
                'Exercises',
                AppTheme.secondaryColor,
              ),
              const SizedBox(width: 12),
              _buildWorkoutStat(
                Icons.local_fire_department_rounded,
                '${workout['calories']} kcal',
                'Calories',
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Areas',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildMuscleGroups(workout['muscleGroups'] ?? []),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Add to calendar
                    HapticFeedback.mediumImpact();
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: const Text('Add to Calendar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _scrollToWorkout(workout['id']);
                  },
                  icon: const Icon(Icons.visibility_rounded, size: 18, color: Colors.white),
                  label: const Text('View Workout', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.75),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedCalendarView() {
    final now = DateTime.now();
    final daysInMonth = _getDaysInMonth(_selectedMonth);
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => 
              SizedBox(
                width: 40,
                child: Text(
                  day,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ).toList(),
          ),
          const SizedBox(height: 16),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: 42, // 6 weeks * 7 days
            itemBuilder: (context, index) {
              final int day = index - (firstWeekday - 1);
              if (day < 0 || day >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(_selectedMonth.year, _selectedMonth.month, day + 1);
              final workouts = _getWorkoutsForDate(date);
              final hasWorkout = workouts.isNotEmpty;
              final isToday = date.year == now.year &&
                            date.month == now.month &&
                            date.day == now.day;
              final isSelected = _selectedDate?.year == date.year &&
                               _selectedDate?.month == date.month &&
                               _selectedDate?.day == date.day;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  HapticFeedback.lightImpact();
                  if (hasWorkout) {
                    _showWorkoutPreviewSheet(context, workouts);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.2)
                      : (hasWorkout 
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday
                        ? AppTheme.primaryColor
                        : Colors.white.withOpacity(0.1),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${day + 1}',
                          style: TextStyle(
                            color: isSelected || isToday
                              ? AppTheme.primaryColor
                              : Colors.white,
                            fontSize: 16,
                            fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasWorkout)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor,
                            ),
                          ).animate(
                            onPlay: (controller) => controller.repeat(),
                          ).shimmer(
                            duration: 2000.ms,
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                    ],
                  ),
                ),
              ).animate()
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutCubic,
                );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsList() {
    final filteredWorkouts = _filteredWorkouts;
    
    return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        // Header section with title
                  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
              'Upcoming Workouts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
        // Filter chips row and search
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Strength'),
                    _buildFilterChip('Cardio'),
                    _buildFilterChip('Flexibility'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Search bar
                      Container(
              width: 200,
              height: 36,
                        decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  border: InputBorder.none,
                  hintText: 'Search workouts...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.5),
                          size: 16,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                          HapticFeedback.lightImpact();
                        },
                      )
                    : Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.5),
                        size: 16,
                      ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredWorkouts.length,
          itemBuilder: (context, index) {
            final workout = filteredWorkouts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildWorkoutCard(workout, index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isActive = _selectedTypeFilters.contains(label);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _handleTypeFilterTap(label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive 
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                ? AppTheme.primaryColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getWorkoutIcon(label),
                size: 14,
                color: isActive
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                    ? AppTheme.primaryColor
                    : Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout, int index) {
    final dateFormat = DateFormat('EEEE, MMMM d');
    final timeFormat = DateFormat('h:mm a');
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Main workout card content
          Row(
            children: [
              _buildWorkoutTypeIcon(workout['focus']),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(workout['date'])} • ${timeFormat.format(workout['date'])}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildWorkoutMenu(),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _buildWorkoutStat(
                Icons.fitness_center_rounded,
                '${workout['exercises']} exercises',
                'Exercises',
                AppTheme.secondaryColor,
              ),
              const SizedBox(width: 12),
              _buildWorkoutStat(
                Icons.timer_rounded,
                workout['duration'],
                'Duration',
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildWorkoutStat(
                Icons.local_fire_department_rounded,
                '${workout['calories']} kcal',
                'Est. Calories',
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quick Actions Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                _buildQuickAction(
                  'Preview',
                  Icons.visibility_rounded,
                  Colors.white.withOpacity(0.75),
                  onTap: () => _showWorkoutPreview(context, workout),
                ),
                _buildQuickAction(
                  'Download',
                  Icons.download_rounded,
                  Colors.white.withOpacity(0.75),
                  onTap: () => _downloadWorkout(workout),
                ),
                _buildQuickAction(
                  'Share',
                  Icons.share_rounded,
                  Colors.white.withOpacity(0.75),
                  onTap: () => _shareWorkout(workout),
                ),
                _buildQuickAction(
                  'Reschedule',
                  Icons.event_rounded,
                  Colors.white.withOpacity(0.75),
                  onTap: () => _rescheduleWorkout(context, workout),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(
        duration: 400.ms,
        delay: Duration(milliseconds: 100 * index),
      )
      .slideY(
        begin: 0.2,
        end: 0,
        duration: 400.ms,
        delay: Duration(milliseconds: 100 * index),
        curve: Curves.easeOutCubic,
      );
  }

  Widget _buildAIInsights(Map<String, dynamic> workout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.purple.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: Colors.blue.withOpacity(0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  color: Colors.blue.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getAIRecommendation(workout),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAIRecommendation(Map<String, dynamic> workout) {
    // In a real app, this would be powered by actual AI based on user's history and progress
    final focus = workout['focus'].toString().toLowerCase();
    if (focus == 'strength') {
      return 'Based on your recent progress, consider increasing weights by 5-10% for compound exercises. Your form has improved significantly.';
    } else if (focus == 'cardio') {
      return 'Your endurance is trending up! This HIIT session is optimized for your current fitness level. Aim to maintain 75-85% max heart rate.';
    } else if (focus == 'core') {
      return 'Your core stability has improved. This session introduces advanced variations of planks and rotational movements.';
    }
    return 'This workout is tailored to your current fitness level and goals. Focus on maintaining proper form throughout.';
  }

  void _showWorkoutPreview(BuildContext context, Map<String, dynamic> workout) {
    // Implement workout preview modal
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildGlassmorphicContainer(
        backgroundColor: const Color(0xFF2A2A2A).withOpacity(0.95),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview content implementation
                  Text(
                    'Workout Preview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Add preview content here
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _downloadWorkout(Map<String, dynamic> workout) {
    // Implement offline download functionality
    HapticFeedback.mediumImpact();
    // Show download progress indicator
  }

  void _rescheduleWorkout(BuildContext context, Map<String, dynamic> workout) {
    // Implement rescheduling modal
    HapticFeedback.mediumImpact();
    // Show date/time picker
  }

  void _shareWorkout(Map<String, dynamic> workout) {
    // Implement sharing functionality
    HapticFeedback.mediumImpact();
    // Show share sheet
  }

  Widget _buildWorkoutTypeIcon(String focus) {
    IconData icon;
    Color color;

    switch (focus.toLowerCase()) {
      case 'strength':
        icon = Icons.fitness_center_rounded;
        color = AppTheme.primaryColor;
        break;
      case 'cardio':
        icon = Icons.directions_run_rounded;
        color = AppTheme.primaryColor;
        break;
      case 'flexibility':
        icon = Icons.self_improvement_rounded;
        color = AppTheme.primaryColor;
        break;
      default:
        icon = Icons.sports_gymnastics_rounded;
        color = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildWorkoutMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF2A2A2A),
      icon: Icon(
        Icons.more_vert_rounded,
        color: Colors.white.withOpacity(0.7),
      ),
      itemBuilder: (context) => [
        'Edit Workout',
        'Reschedule',
        'Share',
        'Add to Calendar',
        'Delete',
      ].map((item) => PopupMenuItem<String>(
        value: item,
        child: Text(
          item,
          style: const TextStyle(color: Colors.white),
        ),
      )).toList(),
    );
  }

  Widget _buildWorkoutStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWorkoutIcon(String focus) {
    switch (focus.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center_rounded;
      case 'cardio':
        return Icons.directions_run_rounded;
      case 'core':
        return Icons.accessibility_new_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  Widget _buildCalendarActionButton(String tooltip, IconData icon, {VoidCallback? onTap}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildIntensityIndicator(String intensity) {
    final Color intensityColor = intensity.toLowerCase() == 'beginner' || intensity.toLowerCase() == 'low'
        ? Colors.green
        : intensity.toLowerCase() == 'intermediate' || intensity.toLowerCase() == 'medium'
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: intensityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: intensityColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.speed_rounded,
            size: 16,
            color: intensityColor,
          ),
          const SizedBox(width: 6),
          Text(
            intensity,
            style: TextStyle(
              color: intensityColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroups(List<String> muscleGroups) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: muscleGroups.map((group) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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
      )).toList(),
    );
  }

  // Add these new variables and methods
  int _visibleDays = 14; // Default to 14, will be updated based on screen width

  void _calculateVisibleDays() {
    if (!_calendarScrollController.hasClients) return;
    
    final width = MediaQuery.of(context).size.width - 48; // Subtract horizontal padding
    final dayWidth = 84.0; // 72 (box width) + 12 (padding)
    _visibleDays = (width / dayWidth).floor();
  }

  void _navigateCalendar(bool forward) {
    if (!_calendarScrollController.hasClients) return;

    final currentOffset = _calendarScrollController.offset;
    final dayWidth = 84.0; // 72 (box width) + 12 (padding)
    final scrollAmount = dayWidth * _visibleDays;

    _calendarScrollController.animateTo(
      forward ? currentOffset + scrollAmount : currentOffset - scrollAmount,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    HapticFeedback.lightImpact();
  }

  Widget _buildSuggestionCard(
    String title,
    String subtitle,
    List<String> items,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
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
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  item,
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

  Widget _buildQuickFilters() {
    return _buildGlassmorphicContainer(
      backgroundColor: Colors.white.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Filters',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Strength'),
                        _buildFilterChip('Cardio'),
                        _buildFilterChip('Flexibility'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search workouts...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutInsights() {
    return _buildGlassmorphicContainer(
      backgroundColor: Colors.white.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Insights',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              'Workout Timing',
              'Best performance window: 3-5 PM',
              Icons.schedule_rounded,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              'Recovery Status',
              'Ready for high intensity workout',
              Icons.battery_charging_full_rounded,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              'Weekly Progress',
              'On track with your training plan',
              Icons.trending_up_rounded,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutSuggestions() {
    return _buildGlassmorphicContainer(
      backgroundColor: Colors.white.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Workouts',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Based on your fitness goals',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _buildSuggestionCard(
              'HIIT Session',
              'High-intensity interval training',
              ['20 min duration', '300 cal burn', 'Full body focus'],
              Icons.flash_on_rounded,
            ),
            const SizedBox(height: 12),
            _buildSuggestionCard(
              'Strength Training',
              'Upper body focus',
              ['45 min duration', '8 exercises', 'Equipment needed'],
              Icons.fitness_center_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color.withOpacity(0.9),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 