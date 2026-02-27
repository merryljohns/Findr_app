import 'package:findr_app/screens/get_started.dart';
import 'package:flutter/material.dart';
import 'package:findr_app/services/item_service.dart';
//import 'package:findr_app/screens/get_started_screen.dart'; // Ensure this path is correct
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ItemService _itemService = ItemService();
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? userData;
  late Future<List<Map<String, dynamic>>> _userPostsFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _userPostsFuture = _itemService.fetchUserPosts();
  }

  Future<void> _loadProfile() async {
    final data = await _itemService.getUserProfile();
    setState(() {
      userData = data;
    });
  }

// Change 'int id' to 'String id'
  void _deletePost(String id) async {
    await _itemService.deleteItem(id);
    setState(() {
      _userPostsFuture = _itemService.fetchUserPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GRADIENT PROFILE CARD ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 218, 175, 243),
                      Color.fromARGB(255, 241, 197, 214)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 45, color: Color(0xFFB9AAFF)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userData?['name'] ?? "Loading...",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(supabase.auth.currentUser?.email ?? "",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 12),
                          _infoRow(Icons.school_outlined,
                              "Dept: ${userData?['department'] ?? 'Information Technology'}"),
                          const SizedBox(height: 4),
                          _infoRow(Icons.calendar_today_outlined,
                              "Year: ${userData?['year'] ?? '3rd Year'}"),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            // --- CREATED POSTS SECTION ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text("Created Posts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            SizedBox(
              height: 250,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _userPostsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF8E7CFF)));
                  }
                  final posts = snapshot.data ?? [];
                  if (posts.isEmpty) {
                    return const Center(
                        child: Text("You haven't posted anything yet.",
                            style: TextStyle(color: Colors.black38)));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        width: 170,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 242, 219, 243),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(25)),
                                  child: Image.network(
                                    post['image_url'] ?? '',
                                    height: 130,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 130,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.black12),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: GestureDetector(
                                    onTap: () => _showDeleteConfirm(post['id']),
                                    child: const CircleAvatar(
                                      radius: 16,
                                      // --- CHANGED to VIOLET shaded ---
                                      backgroundColor: Color(0xFF8E7CFF),
                                      child: Icon(Icons.delete_outline,
                                          size: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post['title'] ?? 'Untitled',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8E7CFF)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      post['category'].toString().toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF8E7CFF),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 60),

            // --- REDUCED WIDTH LOGOUT SLIDER ---
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 60,
                child: Dismissible(
                  key: const Key("logout_swipe"),
                  direction: DismissDirection.startToEnd,
                  confirmDismiss: (direction) async {
                    await supabase.auth.signOut();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GetStartedScreen()),
                        (route) => false,
                      );
                    }
                    return true;
                  },
                  background: Container(
                    padding: const EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB9AAFF), Color(0xFFFBAED3)],
                      ),
                    ),
                    child: const Icon(Icons.logout, color: Colors.white),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EFFF),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: const Color(0xFFDED8FF)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 5,
                          top: 5,
                          bottom: 5,
                          child: Container(
                            width: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFB9AAFF), Color(0xFFFBAED3)],
                              ),
                            ),
                            child: const Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        const Center(
                          child: Text(
                            "Logout",
                            style: TextStyle(
                              color: Color(0xFF8E7CFF),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black45),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }

  void _showDeleteConfirm(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Post?"),
        content: const Text(
            "Are you sure you want to remove this item? This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.black54))),
          ElevatedButton(
              onPressed: () {
                _deletePost(id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF8E7CFF), // Violet for confirmation too
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child:
                  const Text("Delete", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
