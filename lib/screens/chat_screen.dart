import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String itemId;
  final String itemName;
  final String receiverId;
  final String? price;

  const ChatScreen({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.receiverId,
    this.price,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  final Map<String, String> _nameCache = {};

  // FIX: Updated to use the 'name' column as seen in your screenshot
  Future<String> _getUserName(String userId) async {
    if (_nameCache.containsKey(userId)) return _nameCache[userId]!;
    
    try {
      final data = await supabase
          .from('profiles')
          .select('name') // Changed from username to name
          .eq('id', userId)
          .maybeSingle();
      
      final name = data != null ? data['name'] ?? "User" : "User";
      _nameCache[userId] = name;
      return name;
    } catch (e) {
      return "User";
    }
  }

  void _sendMessage() async {
    final String msgText = _messageController.text.trim();
    if (msgText.isEmpty) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    _messageController.clear();

    try {
      await supabase.from('messages').insert({
        'item_id': widget.itemId,
        'text': msgText,
        'sender_id': user.id,
        'receiver_id': widget.receiverId,
      });
    } catch (e) {
      debugPrint("Database Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = supabase.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Color(0xFFE8E0FF),
            child: Icon(Icons.person, color: Color(0xFF8E7CFF)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _getUserName(widget.receiverId),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Chatting...',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
            Text(widget.itemName,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close Chat',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('messages')
                  .stream(primaryKey: ['id'])
                  .eq('item_id', widget.itemId)
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) return const Center(child: Text("No messages yet. Say hi!"));

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final String senderId = message['sender_id'];
                    final bool isMe = senderId == currentUserId;

                    // --- INDIAN TIME (IST) FIX ---
                    DateTime utcTime = DateTime.parse(message['created_at']);
                    DateTime istTime = utcTime.add(const Duration(hours: 5, minutes: 30));
                    
                    String timestamp =
                        "${istTime.hour % 12 == 0 ? 12 : istTime.hour % 12}:${istTime.minute.toString().padLeft(2, '0')} ${istTime.hour >= 12 ? 'PM' : 'AM'}";

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FutureBuilder<String>(
                              future: _getUserName(senderId),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? "...",
                                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF8E7CFF) : const Color(0xFFE8E0FF),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(isMe ? 20 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 20),
                              ),
                            ),
                            child: Text(
                              message['text'] ?? '',
                              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
                            child: Text(
                              timestamp,
                              style: const TextStyle(fontSize: 9, color: Colors.black38),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Color(0xFF8E7CFF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}