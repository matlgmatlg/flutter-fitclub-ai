import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme.dart';
import '../../../core/user_type.dart';
import '../../../widgets/shared/authenticated_layout.dart';
import '../../../widgets/shared/app_navigation.dart';

class AIFeedback extends StatefulWidget {
  const AIFeedback({super.key});

  @override
  State<AIFeedback> createState() => _AIFeedbackState();
}

class _AIFeedbackState extends State<AIFeedback> {
  String _selectedTimeRange = 'Last 30 Days';
  String _selectedInsightType = 'All Insights';
  bool _showTrends = true;

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'AI Form Analysis & Insights',
      userType: UserType.client,
      selectedNavIndex: 2,
      selectedSubNavIndex: 1,
      onNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/client/dashboard');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/client/workouts');
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
            Navigator.pushReplacementNamed(context, '/client/ai-tools/chat');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/client/ai-tools/etc');
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildMainContent(),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 340,
                      child: _buildInsightsSidebar(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildFilterDropdown(
            'Time Range',
            _selectedTimeRange,
            ['Last 7 Days', 'Last 30 Days', 'Last 3 Months', 'Last Year'],
            (value) => setState(() => _selectedTimeRange = value),
          ),
          const SizedBox(width: 16),
          _buildFilterDropdown(
            'Insight Type',
            _selectedInsightType,
            ['All Insights', 'Form Analysis', 'Progress Patterns', 'Recommendations'],
            (value) => setState(() => _selectedInsightType = value),
          ),
          const Spacer(),
          _buildHeaderButton(
            'Show Trends',
            Icons.trending_up_rounded,
            _showTrends,
            (value) => setState(() => _showTrends = value),
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            'Export Report',
            Icons.download_rounded,
            false,
            (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) => onChanged(value!),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            dropdownColor: const Color(0xFF2A2A2A),
            underline: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(
    String label,
    IconData icon,
    bool isActive,
    Function(bool) onPressed,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onPressed(!isActive),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor.withOpacity(0.15) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? AppTheme.primaryColor : Colors.white.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppTheme.primaryColor : Colors.white.withOpacity(0.7),
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

  Widget _buildMainContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallScore(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            _buildExerciseBreakdown(),
                      const SizedBox(height: 32),
                      _buildProgressPatterns(),
                      const SizedBox(height: 32),
                      _buildRecommendations(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallScore() {
    return Container(
        padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
        child: Row(
          children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
              child: Text(
                '85%',
                style: TextStyle(
                color: AppTheme.primaryColor.withOpacity(0.9),
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Form Score',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                  'Your form has improved by 5% since last month. Keep up the great work!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                    height: 1.5,
                  ),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildExerciseBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise Analysis',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildExerciseCard(
          'Squats',
          0.9,
          'Excellent depth and knee alignment. Your core stability has improved significantly.',
          Icons.check_circle_rounded,
          Colors.green,
          ['Depth', 'Knee Alignment', 'Core Stability'],
          [0.95, 0.88, 0.87],
        ),
        const SizedBox(height: 16),
        _buildExerciseCard(
          'Deadlifts',
          0.75,
          'Watch your back position at the start. Hip hinge movement has improved.',
          Icons.warning_rounded,
          Colors.orange,
          ['Back Position', 'Hip Hinge', 'Bar Path'],
          [0.7, 0.85, 0.7],
        ),
      ],
    );
  }

  Widget _buildExerciseCard(
    String exercise,
    double score,
    String feedback,
    IconData icon,
    Color color,
    List<String> metrics,
    List<double> values,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(score * 100).round()}%',
                    style: TextStyle(
                      color: color.withOpacity(0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overall',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(metrics.length, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index > 0 ? 16.0 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
            Text(
                            metrics[index],
                            style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(values[index] * 100).round()}%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(
                          begin: 0,
                          end: values[index],
                        ),
                        builder: (context, value, _) => Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: value,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
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
      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPatterns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Patterns',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI has identified these patterns in your training:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildPatternItem(
                Icons.trending_up_rounded,
                Colors.green,
                'Strength Progress',
                'Your strength increases are most significant when you maintain consistent sleep patterns.',
              ),
              const SizedBox(height: 12),
              _buildPatternItem(
                Icons.schedule_rounded,
                Colors.orange,
                'Recovery Impact',
                'Performance drops by 15% when rest between workouts is less than 48 hours.',
              ),
              const SizedBox(height: 12),
              _buildPatternItem(
                Icons.water_drop_rounded,
                Colors.blue,
                'Hydration Correlation',
                'Form scores improve by 8% on days with optimal hydration levels.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatternItem(IconData icon, Color color, String title, String description) {
    return Row(
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
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Recommendations',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildRecommendationItem(
                Icons.fitness_center_rounded,
                'Adjust Training Split',
                'Consider switching to a 4-day split to optimize recovery between sessions.',
                AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              _buildRecommendationItem(
                Icons.self_improvement_rounded,
                'Mobility Work',
                'Add hip mobility exercises to improve deadlift form.',
                Colors.purple,
              ),
              const SizedBox(height: 16),
              _buildRecommendationItem(
                Icons.restaurant_rounded,
                'Nutrition Timing',
                'Try having your protein shake within 30 minutes post-workout.',
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color.withOpacity(0.9),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSidebar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Quick Insights',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
                    _buildInsightCard(
                      'Form Consistency',
                      '92%',
                      'Maintaining good form across workouts',
                      Icons.analytics_rounded,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildInsightCard(
                      'Recovery Score',
                      '85%',
                      'Based on sleep and workout spacing',
                      Icons.bedtime_rounded,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildInsightCard(
                      'Workout Intensity',
                      '78%',
                      'Relative to your capacity',
                      Icons.speed_rounded,
                      Colors.orange,
            ),
            const SizedBox(height: 16),
                    _buildInsightCard(
                      'Progress Rate',
                      '88%',
                      'Month-over-month improvement',
                      Icons.trending_up_rounded,
                      Colors.purple,
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

  Widget _buildInsightCard(
    String title,
    String score,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(
                  begin: 0,
                  end: double.parse(score.replaceAll('%', '')) / 100,
                ),
                builder: (context, value, _) => FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              score,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 