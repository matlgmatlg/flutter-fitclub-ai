import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/user_type.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/app_navigation.dart';

class Profile extends StatefulWidget {
  final UserType userType;

  const Profile({
    super.key,
    required this.userType,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'John Smith');
  final _emailController = TextEditingController(text: 'john.smith@example.com');
  final _phoneController = TextEditingController(text: '+1 (555) 123-4567');
  bool _isEditMode = false;
  bool _receiveNotifications = true;
  bool _receiveEmails = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Profile',
      userType: widget.userType,
      selectedNavIndex: -1,
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
          case 4:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking');
            break;
          case 5:
            Navigator.pushReplacementNamed(context, '/client/progress-analytics');
            break;
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildPersonalInfo(),
            const SizedBox(height: 24),
            _buildNotificationSettings(),
            const SizedBox(height: 24),
            _buildAccountActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/300?img=${widget.userType == UserType.trainer ? 1 : 2}',
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement image upload
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image upload not implemented yet'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            widget.userType == UserType.trainer ? 'Fitness Trainer' : 'Client',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: Icon(_isEditMode ? Icons.save : Icons.edit),
                    onPressed: () {
                      if (_isEditMode) {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isEditMode = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully'),
                            ),
                          );
                        }
                      } else {
                        setState(() => _isEditMode = true);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                enabled: _isEditMode,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: _isEditMode,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                enabled: _isEditMode,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive app notifications'),
              value: _receiveNotifications,
              onChanged: (bool value) {
                setState(() => _receiveNotifications = value);
              },
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive email updates'),
              value: _receiveEmails,
              onChanged: (bool value) {
                setState(() => _receiveEmails = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                // TODO: Implement password change
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password change not implemented yet'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Settings'),
              onTap: () {
                // TODO: Implement privacy settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy settings not implemented yet'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Log Out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          // TODO: Implement logout
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 