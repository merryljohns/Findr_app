import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MessageService {

  /// SEND MESSAGE
  Future<String?> sendMessage({
    required String itemId,
    required String receiverId,
    required String text,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return "User not logged in";

      await supabase.from('messages').insert({
        'item_id': itemId,
        'sender_id': user.id,
        'receiver_id': receiverId,
        'message': text,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// FETCH CHAT BETWEEN CURRENT USER AND OTHER USER FOR ONE ITEM
  Future<List<Map<String, dynamic>>> fetchChat({
    required String itemId,
    required String otherUserId,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final res = await supabase
        .from('messages')
        .select()
        .eq('item_id', itemId)
        .or(
          'and(sender_id.eq.${user.id},receiver_id.eq.$otherUserId),'
          'and(sender_id.eq.$otherUserId,receiver_id.eq.${user.id})',
        )
        .order('created_at');

    return List<Map<String, dynamic>>.from(res);
  }
  Stream<List<Map<String, dynamic>>> streamChat({
    required String itemId,
    required String otherUserId,
  }) {
    final user = supabase.auth.currentUser;

    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('item_id', itemId)
        .map((rows) {
          return rows.where((msg) {
            return (msg['sender_id'] == user!.id &&
                    msg['receiver_id'] == otherUserId) ||
                (msg['sender_id'] == otherUserId &&
                    msg['receiver_id'] == user.id);
          }).toList();
        });

}}