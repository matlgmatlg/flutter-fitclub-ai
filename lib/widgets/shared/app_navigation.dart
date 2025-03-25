import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/user_type.dart';

class AppNavigation extends StatelessWidget {
  final UserType userType;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppNavigation({
    super.key,
    required this.userType,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          right: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // App Logo/Brand
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Fit',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w100,
                      fontSize: 28,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Club',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor.withOpacity(0.9),
                      fontWeight: FontWeight.w100,
                      fontSize: 28,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildNavigationItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems(BuildContext context) {
    final items = userType == UserType.trainer
        ? [
            _NavItem(
              icon: Icons.people_outline,
              activeIcon: Icons.people,
              label: 'Clients',
              isSelected: selectedIndex == 0,
              onTap: () => onItemSelected(0),
            ),
            _NavItem(
              icon: Icons.analytics_outlined,
              activeIcon: Icons.analytics,
              label: 'AI Reports',
              isSelected: selectedIndex == 1,
              onTap: () => onItemSelected(1),
            ),
            _NavItem(
              icon: Icons.fitness_center_outlined,
              activeIcon: Icons.fitness_center,
              label: 'Workouts',
              isSelected: selectedIndex == 2,
              onTap: () => onItemSelected(2),
            ),
          ]
        : [
            _NavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: 'Dashboard',
              isSelected: selectedIndex == 0,
              onTap: () => onItemSelected(0),
            ),
            _NavItem(
              icon: Icons.fitness_center_outlined,
              activeIcon: Icons.fitness_center,
              label: 'Workouts',
              isSelected: selectedIndex == 1,
              onTap: () => onItemSelected(1),
            ),
            _NavItem(
              icon: Icons.analytics_outlined,
              activeIcon: Icons.analytics,
              label: 'AI Feedback',
              isSelected: selectedIndex == 2,
              onTap: () => onItemSelected(2),
            ),
          ];

    // Add shared items
    items.addAll([
      _NavItem(
        icon: Icons.message_outlined,
        activeIcon: Icons.message,
        label: 'Messages',
        isSelected: selectedIndex == 3,
        onTap: () => onItemSelected(3),
      ),
    ]);

    return items;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
      ),
    );
  }
} 