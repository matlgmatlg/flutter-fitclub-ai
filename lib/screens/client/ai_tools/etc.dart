import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme.dart';
import '../../../core/user_type.dart';
import '../../../widgets/shared/authenticated_layout.dart';

class AIEtcScreen extends StatefulWidget {
  const AIEtcScreen({super.key});

  @override
  State<AIEtcScreen> createState() => _AIEtcScreenState();
}

class _AIEtcScreenState extends State<AIEtcScreen> {
  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Future AI Tools',
      userType: UserType.client,
      selectedNavIndex: 2,
      selectedSubNavIndex: 2,
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
          case 0:
            Navigator.pushReplacementNamed(context, '/client/ai-tools/chat');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/client/ai-tools/feedback');
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exploring the Future of AI in Fitness',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover upcoming AI-powered features that will revolutionize your fitness journey.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildPrioritySection(
                        'MUST HAVE',
                        AppTheme.primaryColor,
                        [
                          _FeatureItem(
                            'Real-time Form Analysis',
                            'AI-powered real-time feedback during workouts using device camera',
                            Icons.camera_rounded,
                            'Coming Q2 2024',
                          ),
                          _FeatureItem(
                            'Smart Workout Adaptation',
                            'Dynamic workout adjustments based on performance and recovery data',
                            Icons.auto_awesome_rounded,
                            'Coming Q2 2024',
                          ),
                          _FeatureItem(
                            'Injury Prevention System',
                            'Proactive movement pattern analysis to prevent potential injuries',
                            Icons.health_and_safety_rounded,
                            'Coming Q3 2024',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildPrioritySection(
                        'SHOULD HAVE',
                        Colors.blue,
                        [
                          _FeatureItem(
                            'Voice-Guided Workouts',
                            'Personalized audio coaching with real-time form cues',
                            Icons.mic_rounded,
                            'Coming Q3 2024',
                          ),
                          _FeatureItem(
                            'Progress Prediction',
                            'ML-based forecasting of strength and physique goals',
                            Icons.trending_up_rounded,
                            'Coming Q4 2024',
                          ),
                          _FeatureItem(
                            'Nutrition Analysis',
                            'Visual food recognition and macro optimization',
                            Icons.restaurant_menu_rounded,
                            'Coming Q4 2024',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildPrioritySection(
                        'COULD HAVE',
                        Colors.purple,
                        [
                          _FeatureItem(
                            'Social AI Trainer',
                            'Community-driven AI coaching with shared insights',
                            Icons.groups_rounded,
                            'Planned 2025',
                          ),
                          _FeatureItem(
                            'Recovery Optimization',
                            'Sleep and recovery analysis with biometric integration',
                            Icons.bedtime_rounded,
                            'Planned 2025',
                          ),
                          _FeatureItem(
                            'AR Workout Experience',
                            'Augmented reality workout guidance and form correction',
                            Icons.view_in_ar_rounded,
                            'Planned 2025',
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

  Widget _buildPrioritySection(
    String title,
    Color color,
    List<_FeatureItem> features,
  ) {
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
              Container(
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: color.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: features.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return _buildFeatureCard(feature, color);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureItem feature, Color color) {
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
                  feature.icon,
                  color: color.withOpacity(0.9),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              feature.timeline,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final String timeline;

  const _FeatureItem(this.title, this.description, this.icon, this.timeline);
} 