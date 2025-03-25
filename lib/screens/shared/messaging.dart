import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/user_type.dart';
import '../../widgets/shared/authenticated_layout.dart';
import '../../widgets/shared/app_navigation.dart';

class Messaging extends StatefulWidget {
  final UserType userType;

  const Messaging({super.key, required this.userType});

  @override
  State<Messaging> createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedContactIndex = 0;

  final List<Map<String, dynamic>> _contacts = [
    {
      'name': 'Coach Mike',
      'role': 'Trainer',
      'image': 'https://i.pravatar.cc/150?img=1',
      'online': true,
      'lastSeen': 'Online',
      'unread': 2,
    },
    {
      'name': 'Sarah Johnson',
      'role': 'Client',
      'image': 'https://i.pravatar.cc/150?img=2',
      'online': false,
      'lastSeen': '2h ago',
      'unread': 0,
    },
    {
      'name': 'John Smith',
      'role': 'Client',
      'image': 'https://i.pravatar.cc/150?img=3',
      'online': true,
      'lastSeen': 'Online',
      'unread': 1,
    },
  ];

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Coach Mike',
      'message': 'Great progress on your bench press form!',
      'time': '2:30 PM',
      'isMe': false,
    },
    {
      'sender': 'Me',
      'message': 'Thanks! I\'ve been practicing the technique you showed me.',
      'time': '2:31 PM',
      'isMe': true,
    },
    {
      'sender': 'Coach Mike',
      'message': 'Keep it up! Let\'s focus on increasing the weight next week.',
      'time': '2:32 PM',
      'isMe': false,
    },
    {
      'sender': 'Me',
      'message': 'Sounds good! Should I maintain the same rep range?',
      'time': '2:33 PM',
      'isMe': true,
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Messages',
      userType: widget.userType,
      selectedNavIndex: 3,
      onNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(
              context,
              widget.userType == UserType.trainer
                  ? '/trainer/client-list'
                  : '/client/dashboard',
            );
            break;
          case 1:
            Navigator.pushNamed(
              context,
              widget.userType == UserType.trainer
                  ? '/trainer/ai-reports'
                  : '/client/workouts',
            );
            break;
          case 2:
            Navigator.pushNamed(
              context,
              widget.userType == UserType.trainer
                  ? '/trainer/workout-creator'
                  : '/client/ai-feedback',
            );
            break;
          case 4:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildContactsList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: _buildChatArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    final filteredContacts = _contacts.where((contact) =>
      contact['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      contact['role']!.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = filteredContacts[index];
              final isSelected = index == _selectedContactIndex;

              return ListTile(
                selected: isSelected,
                selectedTileColor: Colors.grey[100],
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(contact['image']!),
                    ),
                    if (contact['online'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(contact['name']!),
                subtitle: Text(contact['role']!),
                trailing: contact['unread'] > 0
                    ? CircleAvatar(
                        radius: 10,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          contact['unread'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : Text(
                        contact['lastSeen']!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                onTap: () {
                  setState(() {
                    _selectedContactIndex = index;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatArea() {
    if (_contacts.isEmpty) {
      return const Center(
        child: Text('No contacts found'),
      );
    }

    final selectedContact = _contacts[_selectedContactIndex];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(selectedContact['image']!),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedContact['name']!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      selectedContact['online'] ? 'Online' : selectedContact['lastSeen']!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.video_call),
                onPressed: () {
                  // TODO: Implement video call
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Video call not implemented yet'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  // TODO: Implement audio call
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Audio call not implemented yet'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[_messages.length - 1 - index];
              final isMe = message['isMe'];

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Text(
                          message['sender']!,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Text(
                        message['message']!,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        message['time']!,
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {
                  // TODO: Implement file attachment
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File attachment not implemented yet'),
                    ),
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        _messages.add({
                          'sender': 'Me',
                          'message': _messageController.text,
                          'time': '${DateTime.now().hour}:${DateTime.now().minute}',
                          'isMe': true,
                        });
                        _messageController.clear();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 