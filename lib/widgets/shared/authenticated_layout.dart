import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/user_type.dart';
import '../../core/routes.dart';
import 'app_navigation.dart';
import 'breadcrumb_navigation.dart';

class AuthenticatedLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final UserType userType;
  final int selectedNavIndex;
  final Function(int) onNavItemSelected;
  final Widget? floatingActionButton;
  final List<NavigationItem>? subNavItems;
  final int? selectedSubNavIndex;
  final Function(int)? onSubNavItemSelected;

  const AuthenticatedLayout({
    Key? key,
    required this.title,
    required this.child,
    required this.userType,
    required this.selectedNavIndex,
    required this.onNavItemSelected,
    this.floatingActionButton,
    this.subNavItems,
    this.selectedSubNavIndex,
    this.onSubNavItemSelected,
  }) : super(key: key);

  @override
  State<AuthenticatedLayout> createState() => _AuthenticatedLayoutState();
}

class _AuthenticatedLayoutState extends State<AuthenticatedLayout> with SingleTickerProviderStateMixin {
  bool _isCollapsed = false;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(
      begin: 280,
      end: 80,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<NavigationItem> getNavigationItems(UserType userType) {
    switch (userType) {
      case UserType.client:
        return [
          NavigationItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
          ),
          NavigationItem(
            icon: Icons.fitness_center,
            label: 'Workouts',
            subItems: [
              NavigationItem(
                icon: Icons.today,
                label: 'Today',
              ),
              NavigationItem(
                icon: Icons.calendar_today,
                label: 'Upcoming',
              ),
              NavigationItem(
                icon: Icons.history,
                label: 'History',
              ),
              NavigationItem(
                icon: Icons.fitness_center_rounded,
                label: 'My Gym',
              ),
            ],
          ),
          NavigationItem(
            icon: Icons.smart_toy,
            label: 'AI Tools',
            subItems: [
              NavigationItem(
                icon: Icons.chat,
                label: 'AI Chat',
              ),
              NavigationItem(
                icon: Icons.insights,
                label: 'Feedback/Insights',
              ),
              NavigationItem(
                icon: Icons.more_horiz,
                label: 'Etc',
              ),
            ],
          ),
          NavigationItem(
            icon: Icons.psychology_rounded,
            label: 'Coach',
          ),
          NavigationItem(
            icon: Icons.track_changes_rounded,
            label: 'Habit Tracking',
            subItems: [
              NavigationItem(
                icon: Icons.water_drop_rounded,
                label: 'Hydration',
              ),
              NavigationItem(
                icon: Icons.restaurant_rounded,
                label: 'Food',
              ),
              NavigationItem(
                icon: Icons.bedtime_rounded,
                label: 'Sleep',
              ),
              NavigationItem(
                icon: Icons.medication_rounded,
                label: 'Supplement',
              ),
              NavigationItem(
                icon: Icons.healing_rounded,
                label: 'Soreness / Injury',
              ),
            ],
          ),
          NavigationItem(
            icon: Icons.analytics,
            label: 'Progress Analytics',
          ),
        ];
      case UserType.trainer:
        return [
          NavigationItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
          ),
          NavigationItem(
            icon: Icons.people,
            label: 'Clients',
          ),
          NavigationItem(
            icon: Icons.message,
            label: 'Messages',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          _buildSideNavigation(context),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildSideNavigation(BuildContext context) {
    final navItems = getNavigationItems(widget.userType);

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          color: const Color(0xFF1A1A1A),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _isCollapsed ? 16 : 24),
                child: Row(
                  children: [
                    if (!_isCollapsed) ...[
                      RichText(
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
                      const Spacer(),
                    ],
                    IconButton(
                      icon: Icon(
                        _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          _isCollapsed = !_isCollapsed;
                          if (_isCollapsed) {
                            _animationController.forward();
                          } else {
                            _animationController.reverse();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: navItems.length,
                  itemBuilder: (context, index) {
                    final item = navItems[index];
                    final isSelected = widget.selectedNavIndex == index;
                    final hasSubItems = item.subItems != null && isSelected;

                    return Column(
                      children: [
                        _NavItem(
                          icon: item.icon,
                          label: item.label,
                          isSelected: isSelected,
                          isCollapsed: _isCollapsed,
                          onTap: () => widget.onNavItemSelected(index),
                        ),
                        if (hasSubItems && !_isCollapsed)
                          Column(
                            children: item.subItems!.asMap().entries.map((entry) {
                              final subItem = entry.value;
                              final isSubItemSelected = widget.selectedSubNavIndex == entry.key;
                              return _SubNavItem(
                                icon: subItem.icon,
                                label: subItem.label,
                                isSelected: isSubItemSelected,
                                onTap: () {
                                  if (widget.onSubNavItemSelected != null) {
                                    widget.onSubNavItemSelected!(entry.key);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(color: Colors.white24),
              _NavItem(
                icon: Icons.settings,
                label: 'Settings',
                isSelected: false,
                isCollapsed: _isCollapsed,
                onTap: () {
                  Navigator.pushNamed(context, Routes.settings);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final navItems = getNavigationItems(widget.userType);
    final currentNavItem = widget.selectedNavIndex >= 0 && widget.selectedNavIndex < navItems.length
        ? navItems[widget.selectedNavIndex]
        : NavigationItem(icon: Icons.settings, label: 'Settings');
    final hasSubItems = widget.subNavItems != null;
    final currentSubItem = hasSubItems && widget.selectedSubNavIndex != null
        ? widget.subNavItems![widget.selectedSubNavIndex!]
        : null;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // New Breadcrumb Navigation
          Expanded(
            child: BreadcrumbNavigation(
              items: [
                BreadcrumbItem(
                  label: 'Home',
                  icon: Icons.home,
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      widget.userType == UserType.trainer
                          ? '/trainer/client-list'
                          : '/client/dashboard',
                    );
                  },
                ),
                BreadcrumbItem(
                  label: currentNavItem.label,
                  icon: currentNavItem.icon,
                  onTap: currentSubItem != null ? () {
                    switch (currentNavItem.label) {
                      case 'Workouts':
                        Navigator.pushReplacementNamed(context, '/client/workouts');
                        break;
                      // Add other cases as needed
                    }
                  } : null,
                ),
                if (currentSubItem != null)
                  BreadcrumbItem(
                    label: currentSubItem.label,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: Colors.white.withOpacity(0.7),
            onPressed: () {
              // TODO: Show notifications popup
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Notifications'),
                  content: const SizedBox(
                    width: 400,
                    child: Text('No new notifications'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          PopupMenuButton(
            offset: const Offset(0, 40),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                'JD',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Account Settings'),
                onTap: () {
                  Navigator.pushNamed(context, Routes.settings);
                  // TODO: Navigate to account section
                },
              ),
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () {
                  // TODO: Implement logout
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 16 : 24,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.7),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SubNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 48,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final List<NavigationItem>? subItems;

  NavigationItem({
    required this.icon,
    required this.label,
    this.subItems,
  });
} 