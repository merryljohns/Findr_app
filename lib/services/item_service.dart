import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

final supabase = Supabase.instance.client;

class ItemService {
  // --- NEW ADDITION: Fetch User Profile ---

  /// Fetches the current logged-in user's profile data (like their name).
  /// This assumes you have a table named 'profiles' that links to the auth user.
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final res = await supabase
          .from('profiles') // Adjust this to your actual profile table name
          .select('name')
          .eq('id', user.id)
          .single();

      return res;
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  // --- EXISTING METHODS ---

  Future<String?> createItem({
    required String title,
    required String description,
    required String category,
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

  Future<String?> uploadImage(XFile file) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final bytes = await file.readAsBytes();
      final fileName =
          "${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await supabase.storage.from('items').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final publicUrl = supabase.storage.from('items').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      return null;
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

  Future<List<Map<String, dynamic>>> fetchUserPosts() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];
    final res = await supabase
        .from('items')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> deleteItem(String id) async {
    try {
      await supabase.from('items').delete().eq('id', id);
    } catch (e) {
      print("Error deleting item: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecentTwoByCategory(
      String category) async {
    try {
      final res = await supabase
          .from('items')
          .select('title, description, image_url')
          .eq('category', category)
          .order('created_at', ascending: false)
          .limit(2);

      print("Fetched $category: ${res.length} items found");
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("Error fetching $category: $e");
      return [];
    }
  }
}
