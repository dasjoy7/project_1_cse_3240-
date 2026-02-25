import 'package:supabase_flutter/supabase_flutter.dart';

class FriendService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _currentUserId => _client.auth.currentUser!.id;

  // ================= SEND REQUEST =================
  Future<void> sendFriendRequest(String receiverId) async {
    await _client.from('friendships').insert({
      'requester_id': _currentUserId,
      'receiver_id': receiverId,
      'status': 'pending',
    });
  }

  // ================= ACCEPT =================
  Future<void> acceptRequest(String id) async {
    await _client
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('id', id);
  }

  // ================= REJECT / CANCEL =================
  Future<void> removeRequest(String id) async {
    await _client.from('friendships').delete().eq('id', id);
  }

  // ================= BLOCK =================
  Future<void> blockUser(String id) async {
    await _client
        .from('friendships')
        .update({'status': 'blocked'})
        .eq('id', id);
  }

  // ================= GET FRIENDSHIP =================
  Future<Map<String, dynamic>?> getFriendship(String otherUserId) async {
    final response = await _client
        .from('friendships')
        .select()
        .or(
        'and(requester_id.eq.$_currentUserId,receiver_id.eq.$otherUserId),and(requester_id.eq.$otherUserId,receiver_id.eq.$_currentUserId)')
        .maybeSingle();

    return response;
  }

  Future<String?> getFriendshipStatus(String otherUserId) async {
    final data = await getFriendship(otherUserId);
    return data?['status'];
  }

  Future<bool> isFriend(String otherUserId) async {
    final status = await getFriendshipStatus(otherUserId);
    return status == 'accepted';
  }

  // ================= MUTUAL FRIENDS =================
  Future<int> getMutualFriends(String otherUserId) async {
    final myFriends = await _client
        .from('friendships')
        .select('requester_id, receiver_id')
        .eq('status', 'accepted')
        .or(
        'requester_id.eq.$_currentUserId,receiver_id.eq.$_currentUserId');

    final otherFriends = await _client
        .from('friendships')
        .select('requester_id, receiver_id')
        .eq('status', 'accepted')
        .or(
        'requester_id.eq.$otherUserId,receiver_id.eq.$otherUserId');

    final mySet = myFriends
        .map((f) => f['requester_id'] == _currentUserId
        ? f['receiver_id']
        : f['requester_id'])
        .toSet();

    final otherSet = otherFriends
        .map((f) => f['requester_id'] == otherUserId
        ? f['receiver_id']
        : f['requester_id'])
        .toSet();

    return mySet.intersection(otherSet).length;
  }
}