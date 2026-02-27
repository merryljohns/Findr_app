import 'package:findr_app/screens/get_started.dart';
import 'package:flutter/material.dart';
import 'package:findr_app/services/item_service.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final data = await _itemService.getUserProfile();
    setState(() {
      userData = data;
      _userPostsFuture = _itemService.fetchUserPosts();
      _isLoading = false;
    });
  }

  void _deletePost(String id) async {
    await _itemService.deleteItem(id);
    _refreshData();
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userData?['name'] ?? "");
    final deptController = TextEditingController(text: userData?['department'] ?? "");
    final yearController = TextEditingController(text: userData?['year'] ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Edit Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildEditField("Full Name", nameController),
            _buildEditField("Department", deptController),
            _buildEditField("Year", yearController),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E7CFF),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              onPressed: () async {
                final userId = supabase.auth.currentUser?.id;
                if (userId != null) {
                  await supabase.from('profiles').upsert({
                    'id': userId,
                    'name': nameController.text.trim(),
                    'department': deptController.text.trim(),
                    'year': yearController.text.trim(),
                  });
                  Navigator.pop(context);
                  _refreshData();
                }
              },
              child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8F7FF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("My Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: _showEditProfileDialog,
            icon: const Icon(Icons.edit_note, color: Color(0xFF8E7CFF), size: 30),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF8E7CFF),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8E7CFF)))
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // --- VIOLET GRADIENT CARD ---
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8E0FF), Color(0xFFFDE8F3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF8E7CFF).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Text(
                              (userData?['name']?[0] ?? "U").toUpperCase(),
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF8E7CFF)),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userData?['name'] ?? "Loading...", 
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                                // --- EMAIL ADDRESS ---
                                Text(supabase.auth.currentUser?.email ?? "",
                                    style: const TextStyle(fontSize: 12, color: Colors.black45)),
                                const Divider(color: Colors.white54, thickness: 1),
                                // --- DEPARTMENT AND YEAR ---
                                Text("Department: ${userData?['department'] ?? 'Not Set'}", 
                                    style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text("Year: ${userData?['year'] ?? 'Not Set'}", 
                                    style: const TextStyle(fontSize: 14, color: Colors.black54)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Align(alignment: Alignment.centerLeft, child: Text("My Listings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  ),

                  SizedBox(
                    height: 260,
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _userPostsFuture,
                      builder: (context, snapshot) {
                        final posts = snapshot.data ?? [];
                        if (posts.isEmpty) return const Center(child: Text("No posts yet"));
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: posts.length,
                          itemBuilder: (context, index) => _buildPostCard(posts[index]),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                  _buildLogoutSwipe(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFF),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE8E0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: Image.network(post['image_url'] ?? '', height: 140, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(height: 140, color: const Color(0xFFF5F5F7), child: const Icon(Icons.image))),
              ),
              Positioned(
                right: 8, top: 8,
                child: GestureDetector(
                  onTap: () => _showDeleteConfirm(post['id']),
                  child: const CircleAvatar(
                    radius: 18, 
                    backgroundColor: Color(0xFF8E7CFF), 
                    child: Icon(Icons.delete_outline, size: 20, color: Colors.white), 
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(post['title'] ?? 'Untitled', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildLogoutSwipe(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: 65,
      child: Dismissible(
        key: const Key("logout_swipe"),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (dir) async {
          await supabase.auth.signOut();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const GetStartedScreen()), (r) => false);
          return true;
        },
        background: Container(
          padding: const EdgeInsets.only(left: 20),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), gradient: const LinearGradient(colors: [Color(0xFF8E7CFF), Color(0xFFFBAED3)])),
          child: const Icon(Icons.logout, color: Colors.white),
        ),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFF3EFFF), borderRadius: BorderRadius.circular(50), border: Border.all(color: const Color(0xFFDED8FF))),
          child: Stack(
            children: [
              Positioned(left: 5, top: 5, bottom: 5, child: Container(width: 55, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF8E7CFF), Color(0xFFFBAED3)])), child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18))),
              const Center(child: Text("Swipe to Logout", style: TextStyle(color: Color(0xFF8E7CFF), fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Post?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () { _deletePost(id.toString()); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E7CFF)), child: const Text("Delete", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}