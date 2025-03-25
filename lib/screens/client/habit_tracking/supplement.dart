import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme.dart';
import '../../../core/user_type.dart';
import '../../../widgets/shared/authenticated_layout.dart';

class SupplementTrackingScreen extends StatefulWidget {
  const SupplementTrackingScreen({super.key});

  @override
  State<SupplementTrackingScreen> createState() => _SupplementTrackingScreenState();
}

class _SupplementTrackingScreenState extends State<SupplementTrackingScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _supplementController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  String _selectedTime = 'Morning';
  bool _taken = false;

  final List<String> _timings = ['Morning', 'Afternoon', 'Evening', 'Night'];

  // Dummy data for supplement history
  final List<Map<String, dynamic>> _supplementHistory = [
    {
      'name': 'Vitamin D3',
      'dosage': '5000 IU',
      'time': 'Morning',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'taken': true,
      'notes': 'Taken with breakfast',
    },
    {
      'name': 'Omega-3',
      'dosage': '1000mg',
      'time': 'Evening',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'taken': true,
      'notes': 'Taken with dinner',
    },
  ];

  // Common supplements presets
  final List<Map<String, dynamic>> _commonSupplements = [
    {
      'name': 'Vitamin D3',
      'defaultDosage': '5000 IU',
      'recommendedTiming': 'Morning',
      'icon': Icons.wb_sunny_rounded,
      'color': Colors.orange,
    },
    {
      'name': 'Omega-3',
      'defaultDosage': '1000mg',
      'recommendedTiming': 'Evening',
      'icon': Icons.water_drop_rounded,
      'color': Colors.blue,
    },
    {
      'name': 'Magnesium',
      'defaultDosage': '400mg',
      'recommendedTiming': 'Evening',
      'icon': Icons.nights_stay_rounded,
      'color': Colors.purple,
    },
    {
      'name': 'Protein Powder',
      'defaultDosage': '30g',
      'recommendedTiming': 'Post-workout',
      'icon': Icons.fitness_center_rounded,
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Supplement Tracking',
      userType: UserType.client,
      selectedNavIndex: 4,
      selectedSubNavIndex: 3,
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
          case 2:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/sleep');
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
            _buildSupplementHistory(),
          ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildSupplementInsights(),
                                const SizedBox(height: 24),
                                _buildSupplementSchedule(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildQuickLogCard(),
                          const SizedBox(height: 24),
                          _buildSupplementHistory(),
                          const SizedBox(height: 24),
                          _buildSupplementInsights(),
                          const SizedBox(height: 24),
                          _buildSupplementSchedule(),
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
            Icons.medication_rounded,
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
                          'Log Supplement Intake',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                          'Track your supplement intake',
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
              Text(
                'Quick Add Common Supplements',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 115,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _commonSupplements.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final supplement = _commonSupplements[index];
                    return _buildQuickAddCard(
                      supplement['name'],
                      supplement['defaultDosage'],
                      supplement['recommendedTiming'],
                      supplement['icon'],
                      supplement['color'],
                    );
                  },
                ),
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
          TextField(
            controller: _supplementController,
            decoration: InputDecoration(
              labelText: 'Supplement Name',
              hintText: 'Enter supplement name',
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
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dosageController,
            decoration: InputDecoration(
              labelText: 'Dosage',
              hintText: 'Enter dosage (e.g., 500mg)',
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
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Time of Day',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
            ),
          ),
              const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timings.map((time) => _buildTimeChip(time)).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Taken',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: _taken,
                onChanged: (value) => setState(() => _taken = value),
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                    setState(() {
                      _supplementHistory.insert(0, {
                        'name': _supplementController.text,
                        'dosage': _dosageController.text,
                        'time': _selectedTime,
                        'date': _selectedDate,
                        'taken': _taken,
                        'notes': '',
                      });
                      _supplementController.clear();
                      _dosageController.clear();
                      _taken = false;
                    });
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Supplement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
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

  Widget _buildQuickAddCard(
    String name,
    String dosage,
    String timing,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _supplementController.text = name;
          _dosageController.text = dosage;
          _selectedTime = timing;
        });
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
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
            Text(
              name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              dosage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String time) {
    final isSelected = _selectedTime == time;
    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedTime = time);
        }
      },
      backgroundColor: Colors.white.withOpacity(0.05),
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.1),
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.7),
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSupplementHistory() {
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
            'Supplement History',
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
            itemCount: _supplementHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final supplement = _supplementHistory[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        supplement['taken'] ? Icons.check_rounded : Icons.close_rounded,
                        color: supplement['taken'] ? Colors.green : Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplement['name'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${supplement['dosage']} • ${supplement['time']}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${supplement['date'].day}/${supplement['date'].month}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
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

  Widget _buildSupplementInsights() {
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
            'Insights & Analytics',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            title: 'Consistency Score',
            description: '92% adherence to supplement schedule this week',
            icon: Icons.trending_up_rounded,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            title: 'Optimal Timing',
            description: 'Best time to take Vitamin D3 is with breakfast',
            icon: Icons.schedule_rounded,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            title: 'Recommendation',
            description: 'Consider adding Magnesium to your stack',
            icon: Icons.tips_and_updates_rounded,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
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

  Widget _buildSupplementSchedule() {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Daily Schedule',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement schedule editing
                },
                icon: Icon(
                  Icons.edit_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                label: Text(
                  'Edit',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildScheduleItem(
            time: 'Morning',
            supplements: [
              {'name': 'Vitamin D3', 'dosage': '5000 IU', 'taken': true},
              {'name': 'B-Complex', 'dosage': '1 capsule', 'taken': true},
            ],
          ),
          const SizedBox(height: 16),
          _buildScheduleItem(
            time: 'Afternoon',
            supplements: [
              {'name': 'Zinc', 'dosage': '15mg', 'taken': false},
            ],
          ),
          const SizedBox(height: 16),
          _buildScheduleItem(
            time: 'Evening',
            supplements: [
              {'name': 'Magnesium', 'dosage': '400mg', 'taken': false},
              {'name': 'Omega-3', 'dosage': '1000mg', 'taken': false},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem({
    required String time,
    required List<Map<String, dynamic>> supplements,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTimeIcon(time),
                color: _getTimeColor(time),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...supplements.map((supplement) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  supplement['taken'] ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: supplement['taken'] ? Colors.green : Colors.white.withOpacity(0.3),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${supplement['name']} - ${supplement['dosage']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    decoration: supplement['taken'] ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  IconData _getTimeIcon(String time) {
    switch (time) {
      case 'Morning':
        return Icons.wb_sunny_rounded;
      case 'Afternoon':
        return Icons.wb_cloudy_rounded;
      case 'Evening':
        return Icons.nights_stay_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  Color _getTimeColor(String time) {
    switch (time) {
      case 'Morning':
        return Colors.orange;
      case 'Afternoon':
        return Colors.blue;
      case 'Evening':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 
 