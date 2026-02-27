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

  void _sendMessage() async {
    final String msgText = _messageController.text.trim();
    if (msgText.isEmpty) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    _messageController.clear();

    try {
      await supabase.from('messages').insert({
        'item_id': widget.itemId,
        'text': msgText, // Column name is 'text' based on your DB screenshot
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFE8E0FF),
            child: Icon(Icons.person, color: const Color(0xFF8E7CFF)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.itemName, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close Chat', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
      body: Column(
        children: [
          // This Expanded block prevents the "Red Screen" by giving the list room to grow
          // Update this specific block in your ChatScreen.dart
Expanded(
  child: StreamBuilder<List<Map<String, dynamic>>>(
    // 1. We listen to the 'messages' table
    // 2. primaryKey must match your Supabase table's primary key (usually 'id')
    stream: supabase
        .from('messages')
        .stream(primaryKey: ['id']) 
        .eq('item_id', widget.itemId) // Filters messages for this specific item
        .order('created_at', ascending: false),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final messages = snapshot.data ?? [];

      if (messages.isEmpty) {
        return const Center(child: Text("No messages yet. Say hi!"));
      }

      return ListView.builder(
        reverse: true, // Newest messages at the bottom
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final isMe = messages[index]['sender_id'] == currentUserId;
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF8E7CFF) : const Color(0xFFE8E0FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                messages[index]['text'] ?? '',
                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
              ),
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
            decoration: BoxDecoration(color: Colors.white),
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