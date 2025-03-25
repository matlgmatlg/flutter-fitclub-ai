import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/user_type.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/app_navigation.dart';

class AIReports extends StatefulWidget {
  const AIReports({super.key});

  @override
  State<AIReports> createState() => _AIReportsState();
}

class _AIReportsState extends State<AIReports> {
  String _selectedTimeRange = 'This Week';
  String _selectedMetric = 'Form Score';

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'AI Reports',
      userType: UserType.trainer,
      selectedNavIndex: 1,
      onNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/trainer/client-list');
            break;
          case 2:
            Navigator.pushNamed(context, '/trainer/workout-creator');
            break;
          case 3:
            Navigator.pushNamed(context, '/messages');
            break;
          case 4:
            Navigator.pushNamed(
              context,
              '/profile',
              arguments: UserType.trainer,
            );
            break;
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: 24),
            _buildOverallMetrics(),
            const SizedBox(height: 24),
            _buildClientPerformance(),
            const SizedBox(height: 24),
            _buildExerciseAnalysis(),
            const SizedBox(height: 24),
            _buildRecentFeedback(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedTimeRange,
            decoration: InputDecoration(
              labelText: 'Time Range',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: ['Today', 'This Week', 'This Month', 'Last 3 Months']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedTimeRange = newValue;
                });
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedMetric,
            decoration: InputDecoration(
              labelText: 'Primary Metric',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: ['Form Score', 'Completion Rate', 'Progress Rate']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedMetric = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverallMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Performance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Average Form Score',
                '85%',
                Icons.fitness_center,
                AppTheme.primaryColor,
                '+5% from last week',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Workout Completion',
                '92%',
                Icons.check_circle,
                Colors.green,
                'On track',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Client Engagement',
                '78%',
                Icons.people,
                Colors.orange,
                'Needs attention',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon,
      Color color, String trend) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trend,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client Performance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=${index + 1}',
                  ),
                ),
                title: Text('Client ${index + 1}'),
                subtitle: const Text('Last workout: Yesterday'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${90 - index * 5}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.trending_up,
                      color: Colors.green[700],
                    ),
                  ],
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/trainer/client-details',
                  arguments: {'index': index},
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise Analysis',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildExerciseRow('Squats', 0.85),
                _buildExerciseRow('Deadlifts', 0.78),
                _buildExerciseRow('Bench Press', 0.92),
                _buildExerciseRow('Pull-ups', 0.70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseRow(String exercise, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(exercise),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: score,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(score * 100).toInt()}% Form Score',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFeedback() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent AI Feedback',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Form Correction Needed'),
                subtitle: Text(
                  'Client ${index + 1}\'s squat depth needs attention. '
                  'Hip mobility exercises recommended.',
                ),
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.warning, color: Colors.white),
                ),
                trailing: Text(
                  '${index + 1}h ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 