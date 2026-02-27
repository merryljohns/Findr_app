import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthService {

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String dept,
    required String year,
  }) async {
    try {
      // Step 1: Create auth account
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) return "Signup failed";

      // Step 2: Update profile (trigger already created empty row)
      await supabase.from('profiles').update({
        'name': name,
        'department': dept,
        'year': year,
      }).eq('id', user.id);

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

}