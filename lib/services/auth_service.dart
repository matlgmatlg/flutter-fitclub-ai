import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Sign up a new user
  Future<void> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(email: email, password: password);
      if (response.user == null) {
        throw Exception('Sign-up failed.');
      }
    } catch (e) {
      throw Exception('Sign-up failed: $e');
    }
  }

  // Log in a user
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Login failed: No active session.');
      }

      print("✅ Login successful: ${response.user!.email}"); // Debugging log
      return true; // ✅ Return true if login succeeds
    } catch (e) {
      print("❌ Login error: $e"); // Debugging log
      return false; // ✅ Return false if login fails
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.fitclub://reset-callback/',
      );
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Log out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return supabase.auth.currentSession != null;
  }
}