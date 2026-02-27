import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ItemService {

  Future<String?> createItem({
    required String title,
    required String description,
    required String category, // lost / found / resell
    required String location,
    String? imageUrl,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return "User not logged in";

      await supabase.from('items').insert({
        'user_id': user.id,
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'image_url': imageUrl,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final res = await supabase
        .from('items')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchByCategory(String category) async {
    final res = await supabase
        .from('items')
        .select()
        .eq('category', category)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }
}