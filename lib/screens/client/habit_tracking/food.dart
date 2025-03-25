import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme.dart';
import '../../../core/user_type.dart';
import '../../../widgets/shared/authenticated_layout.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';

class FoodTrackingScreen extends StatefulWidget {
  const FoodTrackingScreen({super.key});

  @override
  State<FoodTrackingScreen> createState() => _FoodTrackingScreenState();
}

class _FoodTrackingScreenState extends State<FoodTrackingScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _mealDescription = '';
  final TextEditingController _mealController = TextEditingController();
  String _selectedMealType = 'Breakfast';
  String _selectedLocation = 'Home Cooked';
  DateTime _selectedDate = DateTime.now();
  XFile? _mealImage;
  final ImagePicker _picker = ImagePicker();

  // Dummy data for recent meals
  final List<Map<String, dynamic>> _recentMeals = [
    {
      'type': 'Breakfast',
      'description': 'Oatmeal with berries and honey',
      'time': '8:30 AM',
      'location': 'Home Cooked',
      'image': null,
    },
    {
      'type': 'Lunch',
      'description': 'Grilled chicken salad with avocado',
      'time': '12:45 PM',
      'location': 'Restaurant',
      'image': null,
    },
  ];

  // Favorite meals for quick add
  final List<Map<String, dynamic>> _favoriteMeals = [
    {
      'name': 'Protein Smoothie',
      'type': 'Breakfast',
      'description': 'Banana, protein powder, almond milk',
    },
    {
      'name': 'Chicken Salad',
      'type': 'Lunch',
      'description': 'Grilled chicken, mixed greens, olive oil',
    },
    {
      'name': 'Greek Yogurt',
      'type': 'Snack',
      'description': 'Plain yogurt with honey and nuts',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    await _speech.initialize();
  }

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _mealImage = image;
      });
      // TODO: Implement AI food recognition
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'Food Tracking',
      userType: UserType.client,
      selectedNavIndex: 4,
      selectedSubNavIndex: 1,
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
          case 5:
            Navigator.pushReplacementNamed(context, '/client/progress-analytics');
            break;
        }
      },
      onSubNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/hydration');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/sleep');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/supplement');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/client/habit-tracking/soreness');
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;
            
            return SingleChildScrollView(
              child: Padding(
        padding: const EdgeInsets.all(24),
                child: isWideScreen
                    ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildQuickLogCard(),
                                const SizedBox(height: 24),
                                _buildTodaysMeals(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildQuickAdd(),
                                const SizedBox(height: 24),
                                _buildInsights(),
                                const SizedBox(height: 24),
                                _buildMealSuggestions(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildQuickLogCard(),
                          const SizedBox(height: 24),
                          _buildTodaysMeals(),
                          const SizedBox(height: 24),
                          _buildQuickAdd(),
                          const SizedBox(height: 24),
                          _buildInsights(),
                          const SizedBox(height: 24),
                          _buildMealSuggestions(),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickLogCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
      ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
        children: [
                  Icon(
            Icons.restaurant_rounded,
                    color: AppTheme.primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                          'Log Meal',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                          'Use voice, text, or take a photo of your meal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
              const SizedBox(height: 24),
          Row(
            children: [
                  _buildMealTypeButton('Breakfast', Icons.wb_sunny_outlined),
                  const SizedBox(width: 12),
                  _buildMealTypeButton('Lunch', Icons.wb_sunny_rounded),
                  const SizedBox(width: 12),
                  _buildMealTypeButton('Dinner', Icons.nights_stay_outlined),
                  const SizedBox(width: 12),
                  _buildMealTypeButton('Snack', Icons.cookie_outlined),
                ],
              ),
              const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _mealController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe your meal...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? AppTheme.primaryColor : Colors.white,
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                            IconButton(
                              icon: const Icon(Icons.camera_alt_outlined),
                              onPressed: _takePicture,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_mealImage != null)
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        child: Image.network(
                          _mealImage!.path,
                          fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildLocationToggle('Home Cooked', Icons.home_rounded),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLocationToggle('Restaurant', Icons.restaurant_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                    // TODO: Implement meal logging
                    setState(() {
                      _recentMeals.insert(0, {
                        'type': _selectedMealType,
                        'description': _mealController.text,
                        'time': '${DateTime.now().hour}:${DateTime.now().minute}',
                        'location': _selectedLocation,
                        'image': _mealImage,
                      });
                      _mealController.clear();
                      _mealImage = null;
                    });
                  },
                  label: const Text('Log Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeButton(String type, IconData icon) {
    final isSelected = _selectedMealType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMealType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.1),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationToggle(String label, IconData icon) {
    final isSelected = _selectedLocation == label;
    return InkWell(
      onTap: () => setState(() => _selectedLocation = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.white.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysMeals() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Meals",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentMeals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final meal = _recentMeals[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: meal['image'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                meal['image'].path,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.restaurant_rounded,
                              color: AppTheme.primaryColor,
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                meal['type'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                meal['time'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meal['description'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                meal['location'] == 'Home Cooked'
                                    ? Icons.home_rounded
                                    : Icons.restaurant_rounded,
                                color: Colors.white.withOpacity(0.5),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                meal['location'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAdd() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Add Favorites',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _favoriteMeals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final meal = _favoriteMeals[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedMealType = meal['type'];
                    _mealController.text = meal['description'];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: Colors.red.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal['name'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meal['description'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.add_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Insights',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Meal Timing',
            'Try to eat dinner before 8 PM for better sleep',
            Icons.schedule_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Protein Intake',
            'Consider adding more protein to your breakfast',
            Icons.fitness_center_rounded,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Eating Pattern',
            'You tend to skip breakfast on weekends',
            Icons.insights_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMealSuggestions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meal Suggestions',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Based on your workout schedule',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildSuggestionCard(
            'Post-Workout Meal',
            'High protein meal to support recovery',
            ['Grilled chicken breast', 'Sweet potato', 'Steamed vegetables'],
            Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 12),
          _buildSuggestionCard(
            'Pre-Workout Snack',
            'Light, energizing options',
            ['Banana with peanut butter', 'Greek yogurt with berries'],
            Icons.sports_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
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
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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
    );
  }

  Widget _buildSuggestionCard(
    String title,
    String subtitle,
    List<String> suggestions,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  suggestion,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _mealDescription = result.recognizedWords;
              _mealController.text = _mealDescription;
            });
          },
          cancelOnError: true,
          partialResults: true,
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }
} 