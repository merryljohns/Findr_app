import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthService {

  /// SIGN UP USER + UPDATE PROFILE
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String dept,
    required String year,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) return "Signup failed";

      await supabase.from('profiles').update({
        'name': name,
        'department': dept,
        'year': year,
      }).eq('id', user.id);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// LOGIN USER
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// LOGOUT USER
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  /// GET CURRENT USER
  User? get currentUser => supabase.auth.currentUser;
}