import 'package:flutter/material.dart';
import '../../core/user_type.dart';
import '../../core/theme.dart';
import '../../widgets/shared/authenticated_layout.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Gym Type Enum
enum GymType {
  home,
  commercial,
  outdoor,
  community,
  hotel,
  other
}

// Equipment Category Enum
enum EquipmentCategory {
  cardio,
  freeWeights,
  machines,
  cablesAndPulleys,
  bodyweight,
  accessories,
  specialized
}

// Equipment Model
class Equipment {
  final String id;
  final String name;
  final EquipmentCategory category;
  final int quantity;
  final String? notes;
  final bool isAvailable;

  Equipment({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.notes,
    this.isAvailable = true,
  });
}

// Gym Profile Model
class GymProfile {
  final String id;
  final String name;
  final GymType type;
  final String location;
  final String? notes;
  final bool isPrimary;
  final String? hours;
  final List<Equipment> equipment;

  GymProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    this.notes,
    this.isPrimary = false,
    this.hours,
    this.equipment = const [],
  });
}

class MyGymScreen extends StatefulWidget {
  const MyGymScreen({Key? key}) : super(key: key);

  @override
  State<MyGymScreen> createState() => _MyGymScreenState();
}

class _MyGymScreenState extends State<MyGymScreen> {
  int _selectedNavIndex = 1; // Workouts tab
  int _selectedGymIndex = 0;
  bool _isAddingGym = false;
  bool _isAddingEquipment = false;
  String _searchQuery = '';
  EquipmentCategory? _selectedCategory;

  // Form controllers
  final _gymNameController = TextEditingController();
  final _gymLocationController = TextEditingController();
  final _gymNotesController = TextEditingController();
  final _equipmentNameController = TextEditingController();
  final _equipmentQuantityController = TextEditingController();
  final _equipmentNotesController = TextEditingController();
  GymType _selectedGymType = GymType.home;
  EquipmentCategory _selectedEquipmentCategory = EquipmentCategory.freeWeights;
  final _gymFormKey = GlobalKey<FormState>();
  final _equipmentFormKey = GlobalKey<FormState>();

  // Sample data - In a real app, this would come from a database
  final List<GymProfile> _gymProfiles = [
    GymProfile(
      id: '1',
      name: 'Home Gym',
      type: GymType.home,
      location: 'Delray Beach, FL',
      isPrimary: true,
      equipment: [
        Equipment(
          id: '1',
          name: 'Adjustable Dumbbells',
          category: EquipmentCategory.freeWeights,
          quantity: 2,
        ),
        Equipment(
          id: '2',
          name: 'Pull-up Bar',
          category: EquipmentCategory.bodyweight,
        ),
      ],
    ),
  ];

  GymProfile get _selectedGym => _gymProfiles[_selectedGymIndex];

  @override
  void dispose() {
    _gymNameController.dispose();
    _gymLocationController.dispose();
    _gymNotesController.dispose();
    _equipmentNameController.dispose();
    _equipmentQuantityController.dispose();
    _equipmentNotesController.dispose();
    super.dispose();
  }

  void _resetGymForm() {
    _gymNameController.clear();
    _gymLocationController.clear();
    _gymNotesController.clear();
    _selectedGymType = GymType.home;
  }

  void _resetEquipmentForm() {
    _equipmentNameController.clear();
    _equipmentQuantityController.clear();
    _equipmentNotesController.clear();
    _selectedEquipmentCategory = EquipmentCategory.freeWeights;
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedLayout(
      title: 'My Gym',
      userType: UserType.client,
      selectedNavIndex: 1, // Workouts
      selectedSubNavIndex: 3, // My Gym
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
      onSubNavItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/client/workouts');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/client/upcoming-workouts');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/client/workout-history');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/client/my-gym');
            break;
        }
      },
      child: Stack(
        children: [
          // Background gradient
          Container(
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
          ),
          _buildContent(),
          if (_isAddingGym)
            _buildAddGymOverlay(),
          if (_isAddingEquipment)
            _buildAddEquipmentOverlay(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGymProfilesSection(),
          const SizedBox(height: 24),
          _buildEquipmentManager(),
        ],
      ),
    );
  }

  Widget _buildGymProfilesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.00)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Gyms',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your gym profiles and equipment inventory',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingGym = true;
                    });
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  tooltip: 'Add New Gym',
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          // Gym Profiles List
          Container(
            height: 340,
            padding: const EdgeInsets.all(24),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _gymProfiles.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) => _buildGymProfileCard(_gymProfiles[index], index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymProfileCard(GymProfile gym, int index) {
    final isSelected = index == _selectedGymIndex;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGymIndex = index;
        });
        _showGymActions(gym);
      },
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: isSelected 
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section with Icon and Name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getGymTypeIcon(gym.type),
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gym.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gym.type.toString().split('.').last.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Stats Section
                  Column(
                    children: [
                      _buildGymStat(
                        Icons.location_on_rounded,
                        gym.location,
                        'Location',
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildGymStat(
                        Icons.fitness_center_rounded,
                        '${gym.equipment.length}',
                        'Equipment',
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Primary Badge
            if (gym.isPrimary)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymStat(IconData icon, String value, String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGymActions(GymProfile gym) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              gym.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Colors.white),
              title: const Text(
                'Edit Gym',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text(
                'Delete Gym',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(gym);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(GymProfile gym) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Delete Gym?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${gym.name}? This action cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGymTypeIcon(GymType type) {
    switch (type) {
      case GymType.home:
        return Icons.home;
      case GymType.commercial:
        return Icons.business;
      case GymType.outdoor:
        return Icons.park;
      case GymType.community:
        return Icons.people;
      case GymType.hotel:
        return Icons.hotel;
      case GymType.other:
        return Icons.fitness_center;
    }
  }

  Widget _buildEquipmentManager() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.00)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipment Inventory',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedGym.equipment.length} items available',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Search field
                  Container(
                    width: 250,
                    height: 40,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search equipment...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  // Add Equipment button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isAddingEquipment = true;
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Equipment',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Category filters
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryFilter(null, 'All'),
                ...EquipmentCategory.values.map((category) =>
                  _buildCategoryFilter(category, _formatCategoryName(category)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Equipment list
          _buildEquipmentList(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(EquipmentCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white.withOpacity(0.02),
        selectedColor: AppTheme.primaryColor.withOpacity(0.1),
        side: BorderSide(
          color: isSelected
            ? AppTheme.primaryColor.withOpacity(0.5)
            : Colors.white.withOpacity(0.1),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
      ),
    );
  }

  Widget _buildEquipmentList() {
    final filteredEquipment = _selectedGym.equipment.where((equipment) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!equipment.name.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_selectedCategory != null) {
        if (equipment.category != _selectedCategory) {
          return false;
        }
      }
      return true;
    }).toList();

    if (filteredEquipment.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center,
                size: 48,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No equipment matches your search'
                    : _selectedCategory != null
                        ? 'No ${_formatCategoryName(_selectedCategory!).toLowerCase()} equipment found'
                        : 'No equipment added yet',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isAddingEquipment = true;
                  });
                },
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryColor,
                ),
                label: Text(
                  'Add Equipment',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredEquipment.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildEquipmentItem(filteredEquipment[index]),
    );
  }

  Widget _buildEquipmentItem(Equipment equipment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getEquipmentIcon(equipment.category),
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCategoryName(equipment.category),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: equipment.isAvailable
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: equipment.isAvailable
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Text(
              equipment.isAvailable ? 'Available' : 'Unavailable',
              style: TextStyle(
                color: equipment.isAvailable ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (equipment.quantity > 1)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Text(
                'x${equipment.quantity}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            color: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withOpacity(0.7),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              PopupMenuItem(
                value: 'toggle_availability',
                child: Text(
                  equipment.isAvailable ? 'Mark as Unavailable' : 'Mark as Available',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
            onSelected: (value) => _handleEquipmentAction(value, equipment),
          ),
        ],
      ),
    );
  }

  String _formatCategoryName(EquipmentCategory category) {
    return category.toString().split('.').last
        .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
  }

  IconData _getEquipmentIcon(EquipmentCategory category) {
    switch (category) {
      case EquipmentCategory.cardio:
        return Icons.directions_run;
      case EquipmentCategory.freeWeights:
        return Icons.fitness_center;
      case EquipmentCategory.machines:
        return Icons.settings;
      case EquipmentCategory.cablesAndPulleys:
        return Icons.cable;
      case EquipmentCategory.bodyweight:
        return Icons.accessibility_new;
      case EquipmentCategory.accessories:
        return Icons.sports_handball;
      case EquipmentCategory.specialized:
        return Icons.sports_gymnastics;
    }
  }

  void _handleEquipmentAction(String action, Equipment equipment) {
    switch (action) {
      case 'edit':
        // Show edit equipment dialog
        break;
      case 'toggle_availability':
        // Toggle availability
        break;
      case 'delete':
        // Show delete confirmation dialog
        break;
    }
  }

  Widget _buildAddGymOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 500,
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Form(
            key: _gymFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Text(
                        'Add New Gym',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isAddingGym = false;
                          });
                          _resetGymForm();
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _gymNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Gym Name',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a gym name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<GymType>(
                        value: _selectedGymType,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: const Color(0xFF2A2A2A),
                        decoration: InputDecoration(
                          labelText: 'Gym Type',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        items: GymType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              _formatGymTypeName(type),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (GymType? value) {
                          if (value != null) {
                            setState(() {
                              _selectedGymType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _gymLocationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _gymNotesController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isAddingGym = false;
                                });
                                _resetGymForm();
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitGymForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Add Gym'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddEquipmentOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 500,
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Form(
            key: _equipmentFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Text(
                        'Add Equipment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isAddingEquipment = false;
                          });
                          _resetEquipmentForm();
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _equipmentNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Equipment Name',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter equipment name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<EquipmentCategory>(
                        value: _selectedEquipmentCategory,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: const Color(0xFF2A2A2A),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        items: EquipmentCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              _formatCategoryName(category),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (EquipmentCategory? value) {
                          if (value != null) {
                            setState(() {
                              _selectedEquipmentCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _equipmentQuantityController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          if (int.tryParse(value) == null || int.parse(value) < 1) {
                            return 'Please enter a valid quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _equipmentNotesController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isAddingEquipment = false;
                                });
                                _resetEquipmentForm();
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitEquipmentForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Add Equipment'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatGymTypeName(GymType type) {
    return type.toString().split('.').last
        .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
  }

  void _submitGymForm() {
    if (_gymFormKey.currentState!.validate()) {
      // In a real app, this would save to a database
      final newGym = GymProfile(
        id: DateTime.now().toString(), // Use proper ID generation in real app
        name: _gymNameController.text,
        type: _selectedGymType,
        location: _gymLocationController.text,
        notes: _gymNotesController.text.isEmpty ? null : _gymNotesController.text,
        isPrimary: _gymProfiles.isEmpty, // First gym is primary
      );

      setState(() {
        _gymProfiles.add(newGym);
        _isAddingGym = false;
      });

      _resetGymForm();
    }
  }

  void _submitEquipmentForm() {
    if (_equipmentFormKey.currentState!.validate()) {
      // In a real app, this would save to a database
      final newEquipment = Equipment(
        id: DateTime.now().toString(), // Use proper ID generation in real app
        name: _equipmentNameController.text,
        category: _selectedEquipmentCategory,
        quantity: int.parse(_equipmentQuantityController.text),
        notes: _equipmentNotesController.text.isEmpty ? null : _equipmentNotesController.text,
      );

      setState(() {
        // In a real app, this would update the database
        _gymProfiles[_selectedGymIndex] = GymProfile(
          id: _selectedGym.id,
          name: _selectedGym.name,
          type: _selectedGym.type,
          location: _selectedGym.location,
          notes: _selectedGym.notes,
          isPrimary: _selectedGym.isPrimary,
          equipment: [..._selectedGym.equipment, newEquipment],
        );
        _isAddingEquipment = false;
      });

      _resetEquipmentForm();
    }
  }

  Widget _buildGlassmorphicContainer({
    required Widget child,
    double blur = 10,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }
} 