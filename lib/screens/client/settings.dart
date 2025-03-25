import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/user_type.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/breadcrumb_navigation.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  int _selectedSettingIndex = 0;
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
      begin: 240,
      end: 72,
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

  // Settings Navigation Items
  final List<NavigationItem> _settingsNavItems = [
    NavigationItem(
      icon: Icons.person_outline,
      label: 'Account',
    ),
    NavigationItem(
      icon: Icons.shield_outlined,
      label: 'Privacy & Security',
    ),
    NavigationItem(
      icon: Icons.notifications_outlined,
      label: 'Notifications',
    ),
    NavigationItem(
      icon: Icons.palette_outlined,
      label: 'Appearance',
    ),
    NavigationItem(
      icon: Icons.storage_outlined,
      label: 'Data',
    ),
    NavigationItem(
      icon: Icons.link,
      label: 'Integrations',
    ),
    NavigationItem(
      icon: Icons.accessibility_new_outlined,
      label: 'Accessibility',
    ),
  ];

  // Account Settings
  final _nameController = TextEditingController(text: 'John Smith');
  final _emailController = TextEditingController(text: 'john.smith@example.com');
  final _phoneController = TextEditingController(text: '+1 (555) 123-4567');
  bool _twoFactorEnabled = false;

  // Privacy Settings
  bool _shareWorkoutData = true;
  bool _shareProgressData = true;
  bool _shareHabitData = true;

  // Notification Settings
  bool _workoutReminders = true;
  bool _coachMessages = true;
  bool _progressAlerts = true;
  bool _habitReminders = true;
  bool _aiFeedback = true;

  // App Preferences
  String _selectedTheme = 'dark';
  String _selectedLanguage = 'English';
  String _selectedUnits = 'imperial';
  String _defaultScreen = 'dashboard';
  String _selectedTimeZone = 'EST';

  // Data Management
  bool _autoBackup = true;
  bool _syncEnabled = true;

  // Integration Settings
  bool _healthAppSync = true;
  bool _calendarSync = true;
  bool _deviceSync = false;

  // Accessibility Settings
  double _textSize = 1.0;
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _enableHaptics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
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
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => Container(
                      width: _widthAnimation.value,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              if (!_isCollapsed) ...[
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Text(
                                    'Settings',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
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
                          const SizedBox(height: 32),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _settingsNavItems.length,
                              itemBuilder: (context, index) {
                                final item = _settingsNavItems[index];
                                final isSelected = _selectedSettingIndex == index;
                                return _SettingsNavItem(
                                  icon: item.icon,
                                  label: item.label,
                                  isSelected: isSelected,
                                  isCollapsed: _isCollapsed,
                                  onTap: () => setState(() => _selectedSettingIndex = index),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _settingsNavItems[_selectedSettingIndex].label,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                            ),
                            const SizedBox(height: 32),
                            _buildSettingContent(),
                          ],
                        ),
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
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
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
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: BreadcrumbNavigation(
              items: [
                BreadcrumbItem(
                  label: 'Home',
                  icon: Icons.home,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/client/dashboard');
                  },
                ),
                BreadcrumbItem(
                  label: 'Settings',
                  icon: Icons.settings,
                  onTap: () {
                    setState(() => _selectedSettingIndex = 0);
                  },
                ),
                BreadcrumbItem(
                  label: _settingsNavItems[_selectedSettingIndex].label,
                  icon: _settingsNavItems[_selectedSettingIndex].icon,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingContent() {
    switch (_selectedSettingIndex) {
      case 0:
        return _buildAccountSettings();
      case 1:
        return _buildPrivacySettings();
      case 2:
        return _buildNotificationSettings();
      case 3:
        return _buildAppPreferences();
      case 4:
        return _buildDataManagement();
      case 5:
        return _buildIntegrationSettings();
      case 6:
        return _buildAccessibilitySettings();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return _buildGlassmorphicContainer(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
            ),
            const SizedBox(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Personal Information',
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone',
              icon: Icons.phone_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Security',
          children: [
            _buildSwitchTile(
              title: 'Two-Factor Authentication',
              subtitle: 'Enable additional security',
              value: _twoFactorEnabled,
              onChanged: (value) => setState(() => _twoFactorEnabled = value),
              icon: Icons.security_outlined,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement password change
              },
              icon: const Icon(Icons.lock_outline),
              label: const Text('Change Password'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSectionCard(
      title: 'Data Sharing',
      children: [
        _buildSwitchTile(
          title: 'Share Workout Data',
          subtitle: 'Allow coach to view your workout data',
          value: _shareWorkoutData,
          onChanged: (value) => setState(() => _shareWorkoutData = value),
          icon: Icons.fitness_center_outlined,
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Share Progress Data',
          subtitle: 'Allow coach to view your progress',
          value: _shareProgressData,
          onChanged: (value) => setState(() => _shareProgressData = value),
          icon: Icons.trending_up_outlined,
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Share Habit Data',
          subtitle: 'Allow coach to view your habits',
          value: _shareHabitData,
          onChanged: (value) => setState(() => _shareHabitData = value),
          icon: Icons.track_changes_outlined,
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSectionCard(
      title: 'Notification Preferences',
      children: [
        _buildSwitchTile(
          title: 'Workout Reminders',
          subtitle: 'Get reminded about upcoming workouts',
          value: _workoutReminders,
          onChanged: (value) => setState(() => _workoutReminders = value),
          icon: Icons.fitness_center_outlined,
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Coach Messages',
          subtitle: 'Get notified about coach messages',
          value: _coachMessages,
          onChanged: (value) => setState(() => _coachMessages = value),
          icon: Icons.message_outlined,
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Progress Alerts',
          subtitle: 'Get notified about progress milestones',
          value: _progressAlerts,
          onChanged: (value) => setState(() => _progressAlerts = value),
          icon: Icons.emoji_events_outlined,
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Habit Reminders',
          subtitle: 'Get reminded about habit tracking',
          value: _habitReminders,
          onChanged: (value) => setState(() => _habitReminders = value),
          icon: Icons.track_changes_outlined,
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'AI Feedback',
          subtitle: 'Get notified about AI form analysis',
          value: _aiFeedback,
          onChanged: (value) => setState(() => _aiFeedback = value),
          icon: Icons.psychology_outlined,
        ),
      ],
    );
  }

  Widget _buildAppPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Display',
          children: [
            _buildDropdownTile(
              title: 'Theme',
              value: _selectedTheme,
              items: const {'dark': 'Dark', 'light': 'Light'},
              onChanged: (value) => setState(() => _selectedTheme = value!),
              icon: Icons.palette_outlined,
            ),
            const SizedBox(height: 16),
            _buildDropdownTile(
              title: 'Language',
              value: _selectedLanguage,
              items: const {'English': 'English', 'Spanish': 'Spanish'},
              onChanged: (value) => setState(() => _selectedLanguage = value!),
              icon: Icons.language_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Preferences',
          children: [
            _buildDropdownTile(
              title: 'Units',
              value: _selectedUnits,
              items: const {'metric': 'Metric', 'imperial': 'Imperial'},
              onChanged: (value) => setState(() => _selectedUnits = value!),
              icon: Icons.straighten_outlined,
            ),
            const SizedBox(height: 16),
            _buildDropdownTile(
              title: 'Default Screen',
              value: _defaultScreen,
              items: const {
                'dashboard': 'Dashboard',
                'workouts': 'Workouts',
                'habits': 'Habit Tracking'
              },
              onChanged: (value) => setState(() => _defaultScreen = value!),
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 16),
            _buildDropdownTile(
              title: 'Time Zone',
              value: _selectedTimeZone,
              items: const {'EST': 'Eastern', 'CST': 'Central', 'PST': 'Pacific'},
              onChanged: (value) => setState(() => _selectedTimeZone = value!),
              icon: Icons.schedule_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Sync & Backup',
          children: [
            _buildSwitchTile(
              title: 'Auto Backup',
              subtitle: 'Automatically backup your data',
              value: _autoBackup,
              onChanged: (value) => setState(() => _autoBackup = value),
              icon: Icons.backup_outlined,
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Sync',
              subtitle: 'Keep data synced across devices',
              value: _syncEnabled,
              onChanged: (value) => setState(() => _syncEnabled = value),
              icon: Icons.sync_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Data Management',
          children: [
            ListTile(
              leading: const Icon(Icons.download_outlined, color: AppTheme.primaryColor),
              title: const Text('Export Data', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                'Download your data as a file',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              onTap: () {
                // Implement data export
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Clear Data', style: TextStyle(color: Colors.red)),
              subtitle: Text(
                'Clear all local data',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              onTap: () {
                // Show clear data confirmation dialog
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntegrationSettings() {
    return _buildSectionCard(
      title: 'Connected Services',
      children: [
        _buildSwitchTile(
          title: 'Health App',
          subtitle: 'Sync with Apple Health/Google Fit',
          value: _healthAppSync,
          onChanged: (value) => setState(() => _healthAppSync = value),
          icon: Icons.favorite_border,
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Calendar',
          subtitle: 'Sync workouts with calendar',
          value: _calendarSync,
          onChanged: (value) => setState(() => _calendarSync = value),
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Fitness Devices',
          subtitle: 'Connect with fitness trackers',
          value: _deviceSync,
          onChanged: (value) => setState(() => _deviceSync = value),
          icon: Icons.watch_outlined,
        ),
      ],
    );
  }

  Widget _buildAccessibilitySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Visual',
          children: [
            _buildSliderTile(
              title: 'Text Size',
              value: _textSize,
              min: 0.8,
              max: 1.4,
              onChanged: (value) => setState(() => _textSize = value),
              icon: Icons.text_fields_outlined,
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'High Contrast',
              subtitle: 'Increase contrast for better visibility',
              value: _highContrast,
              onChanged: (value) => setState(() => _highContrast = value),
              icon: Icons.contrast_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Interaction',
          children: [
            _buildSwitchTile(
              title: 'Reduce Motion',
              subtitle: 'Minimize animations',
              value: _reduceMotion,
              onChanged: (value) => setState(() => _reduceMotion = value),
              icon: Icons.animation_outlined,
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Haptic Feedback',
              subtitle: 'Enable vibration feedback',
              value: _enableHaptics,
              onChanged: (value) => setState(() => _enableHaptics = value),
              icon: Icons.vibration_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: AppTheme.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            items: items.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList(),
            onChanged: onChanged,
            dropdownColor: const Color(0xFF2A2A2A),
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicContainer({
    required Widget child,
    double blur = 10,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _SettingsNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SettingsNavItem({
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
            horizontal: isCollapsed ? 20 : 24,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.7),
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
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