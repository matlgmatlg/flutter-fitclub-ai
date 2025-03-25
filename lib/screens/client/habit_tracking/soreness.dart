import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme.dart';
import '../../../core/user_type.dart';
import '../../../widgets/shared/authenticated_layout.dart';

class SorenessTrackingScreen extends StatefulWidget {
  const SorenessTrackingScreen({super.key});

  @override
  State<SorenessTrackingScreen> createState() => _SorenessTrackingScreenState();
}

class _SorenessTrackingScreenState extends State<SorenessTrackingScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedBodyPart = 'None';
  int _sorenessLevel = 0;
  String _selectedSorenessType = 'DOMS';
  String _selectedDuration = '1 day';
  final TextEditingController _notesController = TextEditingController();

  final List<String> _bodyParts = [
    'Neck',
    'Shoulders',
    'Upper Back',
    'Lower Back',
    'Chest',
    'Biceps',
    'Triceps',
    'Forearms',
    'Core',
    'Glutes',
    'Quadriceps',
    'Hamstrings',
    'Calves',
  ];

  final List<String> _sorenessTypes = [
    'DOMS',
    'Sharp Pain',
    'Stiffness',
    'Tightness',
    'Burning',
  ];

  final List<String> _durationOptions = [
    '1 day',
    '2 days',
    '3 days',
    '4+ days',
  ];

  // Dummy data for soreness history
  final List<Map<String, dynamic>> _sorenessHistory = [
    {
      'bodyPart': 'Quadriceps',
      'level': 7,
      'type': 'DOMS',
      'duration': '2 days',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'notes': 'After leg day workout',
    },
    {
      'bodyPart': 'Lower Back',
      'level': 4,
      'type': 'Stiffness',
      'duration': '1 day',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'notes': 'Morning stiffness',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Soreness & Injury Tracking',
      userType: UserType.client,
      selectedNavIndex: 4,
      selectedSubNavIndex: 4,
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
          case 3:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/supplement');
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
            _buildSorenessHistory(),
          ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildSorenessAnalytics(),
                                const SizedBox(height: 24),
                                _buildInjurySection(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildQuickLogCard(),
                          const SizedBox(height: 24),
                          _buildSorenessHistory(),
                          const SizedBox(height: 24),
                          _buildSorenessAnalytics(),
                          const SizedBox(height: 24),
                          _buildInjurySection(),
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
                      Icons.fitness_center_rounded,
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
                          'Log Muscle Soreness',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                          'Track your recovery and prevent injuries',
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
          Text(
                'Affected Area',
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
            children: _bodyParts.map((part) => _buildBodyPartChip(part)).toList(),
          ),
          const SizedBox(height: 24),
          Text(
                'Soreness Level: $_sorenessLevel',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getSorenessColor(_sorenessLevel),
              inactiveTrackColor: Colors.white.withOpacity(0.1),
                  thumbColor: _getSorenessColor(_sorenessLevel),
                  overlayColor: _getSorenessColor(_sorenessLevel).withOpacity(0.2),
            ),
            child: Slider(
                  value: _sorenessLevel.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
                  label: _sorenessLevel.toString(),
              onChanged: (value) {
                    setState(() => _sorenessLevel = value.round());
              },
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
                          'Type',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSorenessType,
                              isExpanded: true,
                              dropdownColor: Colors.grey[900],
                              items: _sorenessTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedSorenessType = value);
                                }
                              },
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
                          'Duration',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDuration,
                              isExpanded: true,
                              dropdownColor: Colors.grey[900],
                              items: _durationOptions.map((duration) {
                                return DropdownMenuItem(
                                  value: duration,
                                  child: Text(
                                    duration,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedDuration = value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes',
                  hintText: 'Add details about your soreness...',
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                    if (_selectedBodyPart != 'None') {
                      setState(() {
                        _sorenessHistory.insert(0, {
                          'bodyPart': _selectedBodyPart,
                          'level': _sorenessLevel,
                          'type': _selectedSorenessType,
                          'duration': _selectedDuration,
                          'date': _selectedDate,
                          'notes': _notesController.text,
                        });
                        _notesController.clear();
                        _sorenessLevel = 0;
                        _selectedBodyPart = 'None';
                      });
                    }
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Soreness Data'),
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

  Widget _buildBodyPartChip(String bodyPart) {
    final isSelected = _selectedBodyPart == bodyPart;
    return ChoiceChip(
      label: Text(bodyPart),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedBodyPart = selected ? bodyPart : 'None');
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

  Color _getSorenessColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSorenessHistory() {
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
                    'Soreness History',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          size: 20,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filter',
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
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sorenessHistory.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.white.withOpacity(0.1),
                  height: 32,
                ),
                itemBuilder: (context, index) {
                  final entry = _sorenessHistory[index];
                  final date = entry['date'] as DateTime;
                  final level = entry['level'] as int;
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _getSorenessColor(level),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${date.day}/${date.month}/${date.year}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getSorenessColor(level).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Level ${entry['level']}',
                                    style: TextStyle(
                                      color: _getSorenessColor(level),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry['bodyPart'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildInfoChip(
                                  entry['type'] as String,
                                  Icons.local_hospital_rounded,
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  entry['duration'] as String,
                                  Icons.timer_rounded,
                                ),
                              ],
                            ),
                            if (entry['notes']?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 8),
                              Text(
                                entry['notes'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
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

  Widget _buildSorenessAnalytics() {
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
                'Soreness Analytics',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Most Affected Areas',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMuscleHeatmap(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recovery Patterns',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecoveryTrends(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInjurySection() {
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
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.healing_rounded,
                      color: Colors.red.withOpacity(0.9),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Active Injuries',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildInjuryCard(
                      'Right Knee',
                      'Minor Sprain',
                      'Recovering',
                      '2 weeks',
                      'Cleared for light exercise',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement injury logging
                      },
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Log New Injury'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
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
            icon,
            size: 16,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleHeatmap() {
    // Placeholder for muscle heatmap visualization
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Muscle Group Heatmap',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryTrends() {
    // Placeholder for recovery trends visualization
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Recovery Trend Graph',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInjuryCard(
    String location,
    String type,
    String status,
    String duration,
    String medicalNote,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                location,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(type, Icons.local_hospital_rounded),
              const SizedBox(width: 8),
              _buildInfoChip(duration, Icons.timer_rounded),
            ],
          ),
          if (medicalNote.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      medicalNote,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.red;
      case 'recovering':
        return Colors.orange;
      case 'healed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
} 