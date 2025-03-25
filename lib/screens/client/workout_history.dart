import 'package:flutter/material.dart';
import '../../core/user_type.dart';
import '../../core/theme.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/breadcrumb_navigation.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  int _selectedNavIndex = 1; // Workouts tab
  String _selectedTimeFilter = 'All Time';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Sample completed workouts data
  final List<Map<String, dynamic>> _completedWorkouts = [
    {
      'id': 'w1',
      'title': 'Full Body Strength',
      'trainer': 'Alex Johnson',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'duration': '45 min',
      'difficulty': 'Intermediate',
      'focus': 'Strength',
      'exercises': 8,
      'performance': 92,
      'calories': 450,
      'heartRate': {'avg': 145, 'max': 175},
      'personalBests': ['Bench Press: 185lbs', 'Squats: 225lbs'],
    },
    {
      'id': 'w2',
      'title': 'HIIT Cardio Blast',
      'trainer': 'Sarah Miller',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'duration': '30 min',
      'difficulty': 'Advanced',
      'focus': 'Cardio',
      'exercises': 12,
      'performance': 85,
    },
    {
      'id': 'w3',
      'title': 'Core & Flexibility',
      'trainer': 'Mike Thompson',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'duration': '40 min',
      'difficulty': 'Beginner',
      'focus': 'Core',
      'exercises': 6,
      'performance': 95,
    },
    {
      'id': 'w4',
      'title': 'Upper Body Focus',
      'trainer': 'Alex Johnson',
      'date': DateTime.now().subtract(const Duration(days: 14)),
      'duration': '50 min',
      'difficulty': 'Intermediate',
      'focus': 'Strength',
      'exercises': 10,
      'performance': 88,
    },
    {
      'id': 'w5',
      'title': 'Lower Body Power',
      'trainer': 'Sarah Miller',
      'date': DateTime.now().subtract(const Duration(days: 21)),
      'duration': '55 min',
      'difficulty': 'Advanced',
      'focus': 'Strength',
      'exercises': 9,
      'performance': 90,
    },
  ];

  // Time filter options
  final List<String> _timeFilters = [
    'Today',
    'Last Week',
    'Last Month',
    'Last 3 Months',
    'All Time',
  ];

  // Category filters
  final List<String> _categories = [
    'All',
    'Strength',
    'Cardio',
    'HIIT',
    'Flexibility',
    'Recovery'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Workout History',
      userType: UserType.client,
      selectedNavIndex: _selectedNavIndex,
      selectedSubNavIndex: 2,
      subNavItems: _workoutSubNavItems,
      onNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/client/dashboard');
            break;
          case 1: // Workouts menu
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
          _buildContent(),
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
          _buildFiltersSection(),
          const SizedBox(height: 24),
          _buildWorkoutStats(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildWorkoutsList(),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildPerformanceInsights(),
                    const SizedBox(height: 24),
                    _buildPersonalBests(),
                  ],
                ),
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
                  'Workout History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your progress and celebrate your achievements',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 300,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search workouts...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.5),
            size: 20,
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
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Row(
      children: [
        _buildFilterDropdown(
          value: _selectedTimeFilter,
          items: _timeFilters,
          onChanged: (value) {
            setState(() {
              _selectedTimeFilter = value!;
            });
          },
          icon: Icons.calendar_today,
        ),
        const SizedBox(width: 16),
        _buildFilterDropdown(
          value: _selectedCategory,
          items: _categories,
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
          icon: Icons.fitness_center,
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: value,
            icon: const Icon(Icons.keyboard_arrow_down),
            underline: const SizedBox(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            dropdownColor: const Color(0xFF1A1A1A),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats() {
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
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                'Total Workouts',
                '48',
                Icons.fitness_center,
                AppTheme.primaryColor,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Avg. Duration',
                '45 min',
                Icons.timer,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Total Time',
                '36h',
                Icons.access_time,
                Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Calories Burned',
                '24,500',
                Icons.local_fire_department,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
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
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutsList() {
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
          Text(
            'Completed Workouts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _completedWorkouts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildWorkoutCard(_completedWorkouts[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    final dateFormat = DateFormat('EEEE, MMMM d');
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
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
                      workout['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildWorkoutTag(dateFormat.format(workout['date'])),
                        const SizedBox(width: 8),
                        _buildWorkoutTag(workout['duration']),
                        const SizedBox(width: 8),
                        _buildWorkoutTag(workout['difficulty']),
                      ],
                    ),
                  ],
                ),
              ),
              _buildPerformanceIndicator(workout['performance']),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trainer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout['trainer'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.repeat),
                    label: const Text('Repeat Workout'),
                    onPressed: () {
                      // Schedule this workout again
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.analytics, color: Colors.white),
                    label: const Text(
                      'View Details',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // View detailed performance
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceInsights() {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Performance Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/client/progress-analytics',
                ),
                icon: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                label: Text(
                  'View More',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInsightCard(
            'Consistency Score',
            '92%',
            'Excellent workout consistency!',
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Progress Rate',
            '85%',
            'Strong improvement in strength',
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Recovery Score',
            '78%',
            'Good recovery between workouts',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String score, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                score,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
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
    );
  }

  Widget _buildPersonalBests() {
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
              Text(
                'Personal Bests',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/client/progress-analytics',
                ),
                icon: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                label: Text(
                  'View More',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPersonalBestCard(
            'Bench Press',
            '185 lbs',
            'Achieved today',
            Icons.emoji_events,
            Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildPersonalBestCard(
            'Squats',
            '225 lbs',
            'Achieved 3 days ago',
            Icons.emoji_events,
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalBestCard(
    String exercise,
    String weight,
    String date,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weight,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator(int performance) {
    Color color;
    if (performance >= 90) {
      color = Colors.green;
    } else if (performance >= 70) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '$performance%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
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
} 