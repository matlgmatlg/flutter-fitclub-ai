import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/user_type.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/app_navigation.dart';
import '../../core/translations.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';
import './workouts_new.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  String _t(String key) {
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    return Translations.get(language, key);
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: _t('welcome_message'),
      userType: UserType.client,
      selectedNavIndex: 0,
      onNavItemSelected: (index) {
        switch (index) {
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
          case 5:
            Navigator.pushReplacementNamed(context, '/client/progress-analytics');
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 32),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildProgressOverview(),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildUpcomingWorkout(),
                        const SizedBox(height: 32),
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      children: [
                        _buildAIInsights(),
                        const SizedBox(height: 32),
                        _buildNotifications(),
                      ],
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

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor,
                child: const Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mateus! 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Workout in 2 Hours',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep up the momentum!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/client/workouts'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.75),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildQuickActionCard(
            'Start Workout',
            Icons.play_arrow_rounded,
            AppTheme.primaryColor,
            onTap: () => Navigator.pushNamed(context, '/client/workouts'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickActionCard(
            'Test New Workouts',
            Icons.message_rounded,
            Colors.green,
            onTap: () {
              final route = MaterialPageRoute(
                builder: (context) => const WorkoutsScreen(),
              );
              Navigator.push(context, route);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickActionCard(
            'View Progress',
            Icons.analytics_rounded,
            Colors.orange,
            onTap: () => Navigator.pushNamed(context, '/client/progress-analytics'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
                'Weekly Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'This Week',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  'Workouts',
                  '4/5',
                  Icons.fitness_center_rounded,
                  AppTheme.primaryColor,
                  0.8,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressCard(
                  'Form Score',
                  '92%',
                  Icons.analytics_rounded,
                  Colors.green,
                  0.92,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressCard(
                  'Calories',
                  '2,450',
                  Icons.local_fire_department_rounded,
                  Colors.orange,
                  0.75,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressCard(
                  'Active Minutes',
                  '185',
                  Icons.timer_rounded,
                  Colors.blue,
                  0.65,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String label, String value, IconData icon, Color color, double progress) {
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6,
                width: progress * 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingWorkout() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
                'Today\'s Workout',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                icon: Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                label: Text(
                  'Schedule',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upper Body Strength',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_rounded,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '10:00 AM • 45 minutes',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/client/workouts'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.75),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Color(0xFF404040)),
                const SizedBox(height: 24),
                Text(
                  'Workout Focus',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFocusChip('Chest'),
                    const SizedBox(width: 8),
                    _buildFocusChip('Shoulders'),
                    const SizedBox(width: 8),
                    _buildFocusChip('Triceps'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(
              height: 32,
              color: Color(0xFF404040),
            ),
            itemBuilder: (context, index) {
              return _buildActivityItem(
                index == 0
                    ? 'Completed Lower Body workout'
                    : (index == 1
                        ? 'Achieved new PR on Bench Press'
                        : 'Updated body measurements'),
                index == 0
                    ? '2 hours ago'
                    : (index == 1 ? 'Yesterday' : '2 days ago'),
                index == 0
                    ? Icons.fitness_center_rounded
                    : (index == 1
                        ? Icons.emoji_events_rounded
                        : Icons.straighten_rounded),
                index == 0
                    ? AppTheme.primaryColor
                    : (index == 1 ? Colors.amber : Colors.blue),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
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
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Form Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '92%',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Excellent Form!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Last workout analysis',
                              style: TextStyle(
                                color: Colors.green.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFF404040)),
                const SizedBox(height: 20),
                Text(
                  'Your squat form has improved significantly. Keep focusing on maintaining depth and core engagement.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
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

  Widget _buildNotifications() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(
              height: 32,
              color: Color(0xFF404040),
            ),
            itemBuilder: (context, index) {
              return _buildNotificationItem(
                index == 0
                    ? 'New message from your trainer'
                    : (index == 1
                        ? 'Workout reminder'
                        : 'Weekly progress report available'),
                index == 0
                    ? '5 min ago'
                    : (index == 1 ? '1 hour ago' : '3 hours ago'),
                index == 0
                    ? Icons.message_rounded
                    : (index == 1
                        ? Icons.notifications_rounded
                        : Icons.assessment_rounded),
                index == 0
                    ? Colors.blue
                    : (index == 1
                        ? AppTheme.primaryColor
                        : Colors.orange),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
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
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
} 