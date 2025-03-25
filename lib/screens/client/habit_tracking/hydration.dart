import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme.dart';
import '../../../core/user_type.dart';
import '../../../widgets/shared/authenticated_layout.dart';
import 'package:fl_chart/fl_chart.dart';

class HydrationTrackingScreen extends StatefulWidget {
  const HydrationTrackingScreen({super.key});

  @override
  State<HydrationTrackingScreen> createState() => _HydrationTrackingScreenState();
}

class _HydrationTrackingScreenState extends State<HydrationTrackingScreen> {
  double _waterIntake = 1.2; // Current daily intake in liters
  double _dailyGoal = 3.0; // Daily target in liters
  DateTime _selectedDate = DateTime.now();
  bool _remindersEnabled = true;
  int _reminderInterval = 60; // minutes
  List<dynamic> _customContainers = [0.25, 0.33, 0.5, 0.75, 1.0, 'reset'];
  
  // Dummy data for the week's progress
  final List<double> _weeklyProgress = [2.1, 2.5, 2.8, 2.2, 1.8, 2.9, 1.2];
  
  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Hydration Tracking',
      userType: UserType.client,
      selectedNavIndex: 4,
      selectedSubNavIndex: 0,
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
          case 5:
            Navigator.pushReplacementNamed(context, '/client/progress-analytics');
            break;
        }
      },
      onSubNavItemSelected: (index) {
        switch (index) {
          case 1:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/food');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/sleep');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/supplement');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/soreness');
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
                                _buildMainCard(),
                                const SizedBox(height: 24),
                                _buildWeeklyProgress(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildQuickActions(),
                                const SizedBox(height: 24),
                                _buildSettings(),
                                const SizedBox(height: 24),
                                _buildInsights(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildMainCard(),
                          const SizedBox(height: 24),
                          _buildWeeklyProgress(),
                          const SizedBox(height: 24),
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          _buildSettings(),
                          const SizedBox(height: 24),
                          _buildInsights(),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainCard() {
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
                  Icon(
                    Icons.water_drop_rounded,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Hydration',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your water intake throughout the day',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildProgressIndicator(),
              const SizedBox(height: 32),
              _buildQuickAddGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _waterIntake / _dailyGoal;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_waterIntake.toStringAsFixed(1)}L',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'of ${_dailyGoal.toStringAsFixed(1)}L daily goal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: progress * 100,
              ),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  '${value.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            // Background track
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress fill with animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: progress.clamp(0.0, 1.0),
              ),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 8,
                      width: constraints.maxWidth * animatedProgress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _customContainers.length,
          itemBuilder: (context, index) {
            return _buildQuickAddButton(_customContainers[index]);
          },
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(dynamic amount) {
    final bool isReset = amount == 'reset';
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (isReset) {
            _waterIntake = 0.0;
          } else {
            _waterIntake = (_waterIntake + amount).clamp(0.0, 10.0);
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isReset 
            ? Colors.red.withOpacity(0.1)
            : Colors.white.withOpacity(0.07),
        foregroundColor: isReset ? Colors.red : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        isReset ? 'Reset' : '+${amount.toStringAsFixed(2)}L',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isReset ? Colors.red : Colors.white,
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 4,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[value.toInt()],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}L',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _weeklyProgress.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: entry.key == _weeklyProgress.length - 1
                            ? AppTheme.primaryColor
                            : Colors.white.withOpacity(0.3),
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Adjust Daily Goal',
            Icons.track_changes_rounded,
            AppTheme.primaryColor,
            () {
              // TODO: Show daily goal adjustment dialog
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Manage Containers',
            Icons.water_drop_rounded,
            Colors.blue,
            () {
              // TODO: Show container management dialog
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'View History',
            Icons.history_rounded,
            Colors.purple,
            () {
              // TODO: Show history dialog
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
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
                child: Text(
                  'Reminders',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                  ),
                ),
              ),
              Switch(
                value: _remindersEnabled,
                onChanged: (value) {
                  setState(() => _remindersEnabled = value);
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          if (_remindersEnabled) ...[
            const SizedBox(height: 16),
            Text(
              'Reminder Interval',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<int>(
                value: _reminderInterval,
                isExpanded: true,
                dropdownColor: const Color(0xFF2A2A2A),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                ),
                underline: const SizedBox(),
                items: [30, 45, 60, 90, 120].map((interval) {
                  return DropdownMenuItem(
                    value: interval,
                    child: Text('Every ${interval} minutes'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _reminderInterval = value);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Insights',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Workout Impact',
            'Increase intake by 0.5L on workout days',
            Icons.fitness_center_rounded,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Weather Alert',
            'Hot weather forecasted - consider +20% intake',
            Icons.wb_sunny_rounded,
            Colors.amber,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Trend Analysis',
            'You drink 30% less water on weekends',
            Icons.trending_down_rounded,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
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