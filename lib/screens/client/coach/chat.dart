import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme.dart';
import '../../../core/user_type.dart';
import '../../../widgets/shared/authenticated_layout.dart';

class CoachChatScreen extends StatefulWidget {
  const CoachChatScreen({super.key});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isAttaching = false;
  bool _isRecording = false;

  // Dummy data for demonstration
  final List<_Message> _messages = [
    _Message(
      'Hey John! How are you feeling after yesterday\'s workout?',
      DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      false,
      MessageStatus.seen,
    ),
    _Message(
      'Hi Coach! I\'m feeling great, but my shoulders are a bit sore.',
      DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      true,
      MessageStatus.seen,
    ),
    _Message(
      'That\'s normal after increasing the overhead press weight. Make sure to do the recovery stretches I showed you.',
      DateTime.now().subtract(const Duration(days: 1)),
      false,
      MessageStatus.seen,
    ),
    _Message(
      'Will do! When should we schedule our next form check?',
      DateTime.now().subtract(const Duration(hours: 2)),
      true,
      MessageStatus.seen,
    ),
    _Message(
      'Let\'s do it tomorrow at 2 PM. I\'ll send you a calendar invite.',
      DateTime.now().subtract(const Duration(minutes: 30)),
      false,
      MessageStatus.delivered,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Coach Chat',
      userType: UserType.client,
      selectedNavIndex: 3,
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
            // We're already on the Coach page
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildChatHeader(),
                          Expanded(
                            child: _buildMessageList(),
                          ),
                          _buildMessageInput(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: _buildInfoPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
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
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.1),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
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
                      color: const Color(0xFF1A1A1A),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coach Sarah',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.video_call_rounded,
              color: Colors.white.withOpacity(0.7),
            ),
            tooltip: 'Start Video Call',
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.phone_rounded,
              color: Colors.white.withOpacity(0.7),
            ),
            tooltip: 'Start Voice Call',
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages.reversed.toList()[index];
        final showDate = index == 0 ||
            !_isSameDay(
              message.timestamp,
              _messages.reversed.toList()[index - 1].timestamp,
            );

        return Column(
          children: [
            if (showDate) ...[
              const SizedBox(height: 24),
              _buildDateDivider(message.timestamp),
              const SizedBox(height: 24),
            ],
            _buildMessageBubble(message),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatDate(date),
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_Message message) {
    return Row(
      mainAxisAlignment:
          message.isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!message.isFromMe) ...[
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: const Icon(
              Icons.person_rounded,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: message.isFromMe
                  ? AppTheme.primaryColor.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(message.isFromMe ? 16 : 4),
                bottomRight: Radius.circular(message.isFromMe ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    if (message.isFromMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        _getStatusIcon(message.status),
                        color: message.status == MessageStatus.seen
                            ? Colors.blue
                            : Colors.white.withOpacity(0.5),
                        size: 14,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        if (message.isFromMe) const SizedBox(width: 28),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() => _isAttaching = !_isAttaching);
            },
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: _isAttaching
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.7),
            ),
            tooltip: 'Add Attachment',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _isRecording = !_isRecording);
                    },
                    icon: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: _isRecording
                          ? Colors.red
                          : Colors.white.withOpacity(0.7),
                    ),
                    tooltip: _isRecording ? 'Stop Recording' : 'Voice Message',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                setState(() {
                  _messages.add(
                    _Message(
                      _messageController.text,
                      DateTime.now(),
                      true,
                      MessageStatus.sent,
                    ),
                  );
                  _messageController.clear();
                });
              }
            },
            icon: Icon(
              Icons.send_rounded,
              color: _messageController.text.isEmpty
                  ? Colors.white.withOpacity(0.3)
                  : AppTheme.primaryColor,
            ),
            tooltip: 'Send Message',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
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
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Coach Sarah',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Personal Trainer',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildQuickAction(
                      'View Profile',
                      Icons.person_outline_rounded,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildQuickAction(
                      'View Notes',
                      Icons.note_alt_rounded,
                      Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    _buildQuickAction(
                      'Schedule Session',
                      Icons.calendar_today_rounded,
                      AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Session',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.videocam_rounded,
                              color: AppTheme.primaryColor.withOpacity(0.9),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Form Check',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tomorrow, 2:00 PM',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildQuickAction(String label, IconData icon, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.9),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icons.check_rounded;
      case MessageStatus.delivered:
        return Icons.done_all_rounded;
      case MessageStatus.seen:
        return Icons.done_all_rounded;
    }
  }
}

enum MessageStatus {
  sent,
  delivered,
  seen,
}

class _Message {
  final String text;
  final DateTime timestamp;
  final bool isFromMe;
  final MessageStatus status;

  const _Message(this.text, this.timestamp, this.isFromMe, this.status);
} 