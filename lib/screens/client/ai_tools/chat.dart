import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/user_type.dart';
import '../../../widgets/shared/authenticated_layout.dart';
import 'dart:ui';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
      _messageController.clear();
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(ChatMessage(
          text: "I'm analyzing your fitness data to provide a personalized response...",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'AI Fitness Assistant',
      userType: UserType.client,
      selectedNavIndex: 2,
      selectedSubNavIndex: 0,
      onNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/client/dashboard');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/client/workouts');
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
      onSubNavItemSelected: (index) {
        switch (index) {
          case 1:
            Navigator.pushReplacementNamed(context, '/client/ai-tools/feedback');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/client/ai-tools/etc');
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
          child: Column(
            children: [
              _buildToolbar(),
              const SizedBox(height: 24),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    children: [
                      // Chat area
                      Expanded(
                        flex: 3,
                        child: _buildChatArea(),
                      ),
                      const SizedBox(width: 24),
                      // Context panel
                      SizedBox(
                        width: 340,
                        child: _buildContextPanel(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToolbarButton(
            'New Chat',
            Icons.add_rounded,
            onTap: () {
              setState(() => _messages.clear());
            },
          ),
          _buildToolbarButton(
            'Voice Input',
            Icons.mic_rounded,
            onTap: () {
              // TODO: Implement voice input
            },
          ),
          _buildToolbarButton(
            'Upload Image',
            Icons.image_rounded,
            onTap: () {
              // TODO: Implement image upload
            },
          ),
          const Spacer(),
          _buildToolbarButton(
            'Export Chat',
            Icons.download_rounded,
            onTap: () {
              // TODO: Implement chat export
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(String label, IconData icon, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 8),
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
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
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
              // Messages
              Expanded(
                child: _messages.isEmpty
                    ? _buildWelcomeScreen()
                    : _buildMessagesList(),
              ),
              // Input area
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 48,
                color: AppTheme.primaryColor.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Personal AI Fitness Assistant',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Ask me anything about your fitness journey, workouts, or health goals.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('Analyze my workout progress'),
                _buildSuggestionChip('Suggest exercises for my goals'),
                _buildSuggestionChip('Create a meal plan'),
                _buildSuggestionChip('Tips for better sleep'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleSubmit(text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.primaryColor.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatarIcon(),
            const SizedBox(width: 16),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryColor.withOpacity(0.15)
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 16),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.psychology_rounded,
          color: AppTheme.primaryColor.withOpacity(0.9),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'M',
          style: TextStyle(
            color: Colors.blue.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask me anything about your fitness journey...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onSubmitted: _handleSubmit,
              ),
            ),
          ),
          const SizedBox(width: 16),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _handleSubmit(_messageController.text),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextPanel() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Context & Data',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
                    _buildContextCard(
                      'Recent Workouts',
                      'Upper Body Strength\n2 hours ago',
                      Icons.fitness_center_rounded,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildContextCard(
                      'Health Metrics',
                      'Sleep: 7.5 hrs\nHydration: 2.1L',
                      Icons.monitor_heart_rounded,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildContextCard(
                      'Goals',
                      'Build muscle\nImprove endurance',
                      Icons.track_changes_rounded,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildContextCard(
                      'Nutrition',
                      'Calories: 2,450\nProtein: 180g',
                      Icons.restaurant_rounded,
                      Colors.purple,
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

  Widget _buildContextCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color.withOpacity(0.9),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
} 