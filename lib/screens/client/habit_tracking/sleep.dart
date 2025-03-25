import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme.dart';
import '../../../core/user_type.dart';
import '../../../widgets/shared/authenticated_layout.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 0);
  int _sleepQuality = 3;
  final TextEditingController _notesController = TextEditingController();

  // Dummy data for sleep history
  final List<Map<String, dynamic>> _sleepHistory = [
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'bedTime': const TimeOfDay(hour: 22, minute: 30),
      'wakeTime': const TimeOfDay(hour: 6, minute: 30),
      'quality': 4,
      'duration': '8h',
      'deepSleep': '3h 20m',
      'remSleep': '2h 15m',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'bedTime': const TimeOfDay(hour: 23, minute: 0),
      'wakeTime': const TimeOfDay(hour: 7, minute: 0),
      'quality': 3,
      'duration': '8h',
      'deepSleep': '3h 05m',
      'remSleep': '2h 30m',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Sleep Tracking',
      userType: UserType.client,
      selectedNavIndex: 4,
      selectedSubNavIndex: 2,
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
          case 0:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/hydration');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/food');
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
                                _buildQuickLogCard(),
                                const SizedBox(height: 24),
                                _buildSleepHistory(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildSleepInsights(),
                                const SizedBox(height: 24),
                                _buildSleepGoals(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildQuickLogCard(),
                          const SizedBox(height: 24),
                          _buildSleepHistory(),
                          const SizedBox(height: 24),
                          _buildSleepInsights(),
                          const SizedBox(height: 24),
                          _buildSleepGoals(),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickLogCard() {
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.bedtime_rounded,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Log Sleep',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your sleep duration and quality',
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
              const SizedBox(height: 24),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bed Time',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _bedTime,
                            );
                            if (time != null) {
                              setState(() => _bedTime = time);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.nights_stay_rounded,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _bedTime.format(context),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wake Time',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _wakeTime,
                            );
                            if (time != null) {
                              setState(() => _wakeTime = time);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.wb_sunny_rounded,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _wakeTime.format(context),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Sleep Quality',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return InkWell(
                    onTap: () => setState(() => _sleepQuality = index + 1),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: index < _sleepQuality
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: index < _sleepQuality
                              ? AppTheme.primaryColor
                              : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: index < _sleepQuality
                            ? AppTheme.primaryColor
                            : Colors.white.withOpacity(0.3),
                        size: 24,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add notes about your sleep (optional)',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement sleep logging
                    setState(() {
                      _sleepHistory.insert(0, {
                        'date': _selectedDate,
                        'bedTime': _bedTime,
                        'wakeTime': _wakeTime,
                        'quality': _sleepQuality,
                        'duration': '${_wakeTime.hour - _bedTime.hour}h',
                        'deepSleep': '3h 15m', // TODO: Calculate this
                        'remSleep': '2h 30m', // TODO: Calculate this
                      });
                    });
                  },
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: const Text('Save Sleep Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

  Widget _buildSleepHistory() {
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
            'Sleep History',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sleepHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final sleep = _sleepHistory[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${sleep['date'].day}/${sleep['date'].month}/${sleep['date'].year}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: starIndex < sleep['quality']
                                  ? AppTheme.primaryColor
                                  : Colors.white.withOpacity(0.3),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSleepMetric(
                          'Duration',
                          sleep['duration'],
                          Icons.access_time_rounded,
                        ),
                        _buildSleepMetric(
                          'Deep Sleep',
                          sleep['deepSleep'],
                          Icons.nightlight_round,
                        ),
                        _buildSleepMetric(
                          'REM Sleep',
                          sleep['remSleep'],
                          Icons.remove_red_eye_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSleepMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepInsights() {
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
            'Sleep Insights',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Sleep Schedule',
            'Your sleep schedule has been consistent this week',
            Icons.schedule_rounded,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Sleep Quality',
            'Deep sleep has improved by 12% this week',
            Icons.trending_up_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Recommendation',
            'Try going to bed 30 minutes earlier for optimal rest',
            Icons.tips_and_updates_rounded,
            Colors.orange,
          ),
        ],
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

  Widget _buildSleepGoals() {
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
            'Sleep Goals',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildGoalCard(
            'Sleep Duration',
            '8 hours',
            '7h 45m avg',
            0.95,
            Icons.nightlight_round,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildGoalCard(
            'Consistent Schedule',
            '10:30 PM - 6:30 AM',
            '5/7 days',
            0.71,
            Icons.schedule_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildGoalCard(
            'Deep Sleep',
            '2 hours',
            '1h 45m avg',
            0.85,
            Icons.waves_rounded,
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    String title,
    String target,
    String current,
    double progress,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
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
                      'Target: $target',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                current,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
} 