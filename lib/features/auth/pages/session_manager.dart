import 'package:supabase_flutter/supabase_flutter.dart';

class SessionManager {
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null;
  }

  // Get current user session
  Future<User?> getUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    return user;
  }

  // Log out user
  Future<void> logOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
