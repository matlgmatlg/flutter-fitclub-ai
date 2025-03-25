import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme.dart';
import '../../core/user_type.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/breadcrumb_navigation.dart';

class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  State<ProgressAnalyticsScreen> createState() => _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen> {
  String _selectedTimeRange = '30 Days';
  String _selectedMetric = 'All Metrics';

  final List<String> _timeRanges = [
    '7 Days',
    '30 Days',
    '90 Days',
    '1 Year',
    'All Time',
  ];

  final List<String> _metrics = [
    'All Metrics',
    'Workouts',
    'Nutrition',
    'Sleep',
    'Recovery',
  ];

  // Dummy data for demonstration
  final Map<String, dynamic> _overviewStats = {
    'workoutsCompleted': 24,
    'totalMinutes': 1080,
    'avgPerformance': 88.5,
    'caloriesBurned': 12500,
    'personalRecords': 8,
    'consistencyScore': 92,
  };

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Progress Analytics',
      userType: UserType.client,
      selectedNavIndex: 5,
      selectedSubNavIndex: null,
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
        }
      },
      child: Container(
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildFilters(),
                  const SizedBox(height: 32),
                  if (isWideScreen) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildProgressOverview(),
                              const SizedBox(height: 32),
                              _buildPerformanceMetrics(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            children: [
                              _buildHealthInsights(),
                              const SizedBox(height: 32),
                              _buildPredictiveAnalytics(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildProgressOverview(),
                    const SizedBox(height: 32),
                    _buildPerformanceMetrics(),
                    const SizedBox(height: 32),
                    _buildHealthInsights(),
                    const SizedBox(height: 32),
                    _buildPredictiveAnalytics(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              'Your Progress Story',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              'Track your journey, celebrate your wins',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.insights_rounded,
            color: AppTheme.primaryColor,
            size: 32,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTimeRange,
                isExpanded: true,
                dropdownColor: Colors.grey[900],
                items: _timeRanges.map((range) {
                  return DropdownMenuItem(
                    value: range,
                    child: Text(
                      range,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedTimeRange = value);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMetric,
                isExpanded: true,
                dropdownColor: Colors.grey[900],
                items: _metrics.map((metric) {
                  return DropdownMenuItem(
                    value: metric,
                    child: Text(
                      metric,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMetric = value);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressOverview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress Overview',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_graph_rounded,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Last 30 Days',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isMobile ? 2 : 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isMobile ? 1.2 : 1.4,
                    children: [
                      _buildStatCard(
                        'Workouts',
                        _overviewStats['workoutsCompleted'].toString(),
                        Icons.fitness_center_rounded,
                        AppTheme.primaryColor,
                      ),
                      _buildStatCard(
                        'Minutes',
                        _overviewStats['totalMinutes'].toString(),
                        Icons.timer_rounded,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Performance',
                        '${_overviewStats['avgPerformance']}%',
                        Icons.trending_up_rounded,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Calories',
                        _overviewStats['caloriesBurned'].toString(),
                        Icons.local_fire_department_rounded,
                        Colors.red,
                      ),
                      _buildStatCard(
                        'PRs',
                        _overviewStats['personalRecords'].toString(),
                        Icons.emoji_events_rounded,
                        Colors.amber,
                      ),
                      _buildStatCard(
                        'Consistency',
                        '${_overviewStats['consistencyScore']}%',
                        Icons.calendar_today_rounded,
                        Colors.blue,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Performance Metrics',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_graph_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'View Details',
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
              const SizedBox(height: 24),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Center(
                  child: Text(
                    'Performance Graph',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthInsights() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health & Wellness Insights',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInsightCard(
                      'Sleep',
                      '85%',
                      Icons.nightlight_round,
                      Colors.indigo,
                      'Improved by 12% this month',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInsightCard(
                      'Recovery',
                      '92',
                      Icons.favorite_rounded,
                      Colors.red,
                      'Better than 85% of users',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInsightCard(
                      'Nutrition',
                      '78%',
                      Icons.restaurant_rounded,
                      Colors.orange,
                      'Room for improvement',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInsightCard(
                      'Hydration',
                      '95%',
                      Icons.water_drop_rounded,
                      Colors.blue,
                      'Excellent consistency',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              SelectableText(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictiveAnalytics() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: AppTheme.primaryColor.withOpacity(0.9),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Predictions & Insights',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPredictionCard(
                'Goal Achievement',
                'You\'re on track to reach your strength goal by October 2024',
                Icons.track_changes_rounded,
                AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              _buildPredictionCard(
                'Recovery Optimization',
                'Consider reducing workout intensity next week based on recent soreness patterns',
                Icons.healing_rounded,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildPredictionCard(
                'Performance Trend',
                'Your current trajectory suggests a 15% strength increase in the next 3 months',
                Icons.trending_up_rounded,
                Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  description,
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
}