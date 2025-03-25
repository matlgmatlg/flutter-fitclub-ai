import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/user_type.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/app_navigation.dart';

class ClientList extends StatefulWidget {
  const ClientList({super.key});

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _clients = [
    {
      'name': 'John Smith',
      'goal': 'Weight Loss',
      'image': 'https://example.com/john.jpg',
      'progress': '75%',
      'nextSession': 'Tomorrow at 10:00 AM',
    },
    {
      'name': 'Jane Doe',
      'goal': 'Muscle Gain',
      'image': 'https://example.com/jane.jpg',
      'progress': '60%',
      'nextSession': 'Thursday at 2:00 PM',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'My Clients',
      userType: UserType.trainer,
      selectedNavIndex: 0,
      onNavItemSelected: (index) {
        switch (index) {
          case 1:
            Navigator.pushNamed(context, '/trainer/ai-reports');
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClientDialog(context),
        backgroundColor: AppTheme.primaryColor,
        label: const Text('Add Client'),
        icon: const Icon(Icons.person_add),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: _buildClientList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClientList() {
    final clients = _clients.where((client) => 
      client['name']!.toLowerCase().contains(_searchQuery) ||
      client['goal']!.toLowerCase().contains(_searchQuery)
    ).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _showClientDetails(context, client),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(client['image']!),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client['name']!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client['goal']!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: double.parse(client['progress']!.replaceAll('%', '')) / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Next session: ${client["nextSession"]}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, client),
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'message',
                        child: Text('Message'),
                      ),
                      const PopupMenuItem(
                        value: 'workout',
                        child: Text('Assign Workout'),
                      ),
                      const PopupMenuItem(
                        value: 'progress',
                        child: Text('View Progress'),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text('Remove Client'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddClientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter client\'s email',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Initial Goal',
                hintText: 'Enter client\'s fitness goal',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add client logic
              Navigator.pop(context);
            },
            child: const Text('Send Invitation'),
          ),
        ],
      ),
    );
  }

  void _showClientDetails(BuildContext context, Map<String, String> client) {
    Navigator.pushNamed(context, '/trainer/client-details', arguments: client);
  }

  void _handleMenuAction(String value, Map<String, String> client) {
    switch (value) {
      case 'message':
        Navigator.pushNamed(context, '/messages', arguments: client);
        break;
      case 'workout':
        Navigator.pushNamed(context, '/trainer/workout-creator', arguments: client);
        break;
      case 'progress':
        Navigator.pushNamed(context, '/trainer/client-details', arguments: client);
        break;
      case 'remove':
        _showRemoveClientDialog(context, client);
        break;
    }
  }

  void _showRemoveClientDialog(BuildContext context, Map<String, String> client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Client'),
        content: Text('Are you sure you want to remove ${client["name"]}?'),
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
              // TODO: Implement remove client logic
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
} 