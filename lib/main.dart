import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/auth/login_page.dart';
import 'services/auth_service.dart';
import 'screens/landing_page.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'package:camera/camera.dart';
import 'services/camera_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting
  await initializeDateFormatting('pt_BR', null);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://abnbwnukxzsfxhhcrnwl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFibmJ3bnVreHpzZnhoaGNybndsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExMDgyMTQsImV4cCI6MjA1NjY4NDIxNH0.3Af2jJEKY1w6IdDrlyY3gFkme6heYztzntfSOE3CV9I',
  );

  // Initialize camera service
  try {
    final cameraService = CameraService.instance;
    await cameraService.initialize();
    debugPrint('Camera initialized successfully');
  } catch (e) {
    debugPrint('Warning: Failed to initialize camera: $e');
    // Continue app initialization even if camera fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MaterialApp(
        title: 'FitClub AI',
        theme: AppTheme.darkTheme,
        onGenerateRoute: Routes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supabase Auth')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _authService.signUp(_emailController.text, _passwordController.text);
                  setState(() {
                    _message = 'Sign-up successful!';
                  });
                } catch (e) {
                  setState(() {
                    _message = 'Sign-up failed: $e';
                  });
                }
              },
              child: Text('Sign Up'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _authService.signIn(_emailController.text, _passwordController.text);
                  setState(() {
                    _message = 'Login successful!';
                  });
                } catch (e) {
                  setState(() {
                    _message = 'Login failed: $e';
                  });
                }
              },
              child: Text('Log In'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _authService.signOut();
                setState(() {
                  _message = 'Logged out!';
                });
              },
              child: Text('Log Out'),
            ),
            SizedBox(height: 20),
            Text(_message, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}