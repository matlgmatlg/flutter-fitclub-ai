import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/app_navigation.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Dashboard',
      userType: UserType.trainer,
      selectedNavIndex: 0,
      onNavItemSelected: (index) {
        switch (index) {
          case 1:
            Navigator.pushNamed(context, '/trainer/clients');
            break;
          case 2:
            Navigator.pushNamed(context, '/trainer/ai-reports');
            break;
          case 3:
            Navigator.pushNamed(context, '/trainer/messages');
            break;
          case 4:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/trainer/workout-creator'),
        backgroundColor: AppTheme.brandColor,
        child: const Icon(Icons.add),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Trainer',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            _buildClientActivitySummary(),
            const SizedBox(height: 24),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildClientActivitySummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Client Activity',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            // Add client activity widgets here
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildActionCard(
          context,
          'Assign Workout',
          Icons.fitness_center,
          () => Navigator.pushNamed(context, '/trainer/workout-creator'),
        ),
        _buildActionCard(
          context,
          'View AI Reports',
          Icons.analytics,
          () => Navigator.pushNamed(context, '/trainer/ai-reports'),
        ),
        _buildActionCard(
          context,
          'Manage Clients',
          Icons.people,
          () => Navigator.pushNamed(context, '/trainer/clients'),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppTheme.brandColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 