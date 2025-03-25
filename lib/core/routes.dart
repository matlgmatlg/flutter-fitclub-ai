import 'package:flutter/material.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/register_page.dart';
import '../screens/client/client_dashboard.dart';
import '../screens/client/workouts.dart';
import '../screens/client/upcoming_workouts.dart';
import '../screens/client/workout_history.dart';
import '../screens/client/my_gym.dart';
import '../screens/client/ai_tools/chat.dart';
import '../screens/client/ai_tools/feedback.dart';
import '../screens/client/ai_tools/etc.dart';
import '../screens/client/coach/chat.dart';
import '../screens/client/habit_tracking/hydration.dart';
import '../screens/client/habit_tracking/food.dart';
import '../screens/client/habit_tracking/sleep.dart';
import '../screens/client/habit_tracking/supplement.dart';
import '../screens/client/habit_tracking/soreness.dart';
import '../screens/client/progress_analytics.dart';
import '../screens/shared/profile.dart';
import '../core/user_type.dart';
import '../screens/client/settings.dart';
import '../screens/landing_page.dart';

class Routes {
  static const String settings = '/client/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LandingPage());

      // Auth Routes
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      // Client Routes
      case '/client/dashboard':
        return MaterialPageRoute(builder: (_) => const ClientDashboard());
      case '/client/workouts':
        return MaterialPageRoute(builder: (_) => const WorkoutsScreen());
      case '/client/upcoming-workouts':
        return MaterialPageRoute(builder: (_) => const UpcomingWorkoutsScreen());
      case '/client/workout-history':
        return MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen());
      case '/client/my-gym':
        return MaterialPageRoute(builder: (_) => const MyGymScreen());

      // AI Tools Routes
      case '/client/ai-tools/chat':
        return MaterialPageRoute(builder: (_) => const AIChatScreen());
      case '/client/ai-tools/feedback':
        return MaterialPageRoute(builder: (_) => const AIFeedback());
      case '/client/ai-tools/etc':
        return MaterialPageRoute(builder: (_) => const AIEtcScreen());

      // Coach Routes
      case '/client/coach':
        return MaterialPageRoute(builder: (_) => const CoachChatScreen());

      // Habit Tracking Routes
      case '/client/habit-tracking':
      case '/client/habit-tracking/hydration':
        return MaterialPageRoute(builder: (_) => const HydrationTrackingScreen());
      case '/client/habit-tracking/food':
        return MaterialPageRoute(builder: (_) => const FoodTrackingScreen());
      case '/client/habit-tracking/sleep':
        return MaterialPageRoute(builder: (_) => const SleepTrackingScreen());
      case '/client/habit-tracking/supplement':
        return MaterialPageRoute(builder: (_) => const SupplementTrackingScreen());
      case '/client/habit-tracking/soreness':
        return MaterialPageRoute(builder: (_) => const SorenessTrackingScreen());

      // Progress Analytics Route
      case '/client/progress-analytics':
        return MaterialPageRoute(builder: (_) => const ProgressAnalyticsScreen());

      // Profile Route
      case '/profile':
        final userType = settings.arguments as UserType;
        return MaterialPageRoute(builder: (_) => Profile(userType: userType));

      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 