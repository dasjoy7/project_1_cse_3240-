import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'friend_service.dart';
import 'chat_page.dart';

class FindFriendsPage extends StatefulWidget {
  const FindFriendsPage({super.key});

  @override
  State<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  final _client = Supabase.instance.client;
  final FriendService _friendService = FriendService();

  @override
  Widget build(BuildContext context) {
    final currentUser = _client.auth.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("User not logged in"));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Find Friends"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _client.from('profile').select(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = (snapshot.data as List)
              .where((u) => u['id'] != currentUser.id)
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];


              return FutureBuilder<Map<String, dynamic>?>(
                future: _friendService.getFriendship(user['id']),
                builder: (context, snap) {
                  Widget button;

                  final data = snap.data;

                  if (data == null) {
                    // No relationship
                    button = ElevatedButton(
                      onPressed: () async {
                        await _friendService.sendFriendRequest(user['id']);
                        setState(() {});
                      },
                      child: const Text("Add"),
                    );
                  } else {
                    final status = data['status'];
                    final requesterId = data['requester_id'];
                    final receiverId = data['receiver_id'];

                    if (status == 'pending') {
                      if (requesterId == _client.auth.currentUser!.id) {
                        // I sent request
                        button = const Text("Pending");
                      } else {
                        // I received request
                        button = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                await _friendService.acceptRequest(data['id']);
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                await _friendService.removeRequest(data['id']);
                                setState(() {});
                              },
                            ),
                          ],
                        );
                      }
                    }
                    else if (status == 'accepted') {
                      button = ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                receiverId: user['id'],
                                receiverName: user['full_name'],
                              ),
                            ),
                          );
                        },
                        child: const Text("Chat"),
                      );
                    }
                    else if (status == 'blocked') {
                      button = const Text("Blocked");
                    }
                    else {
                      button = const SizedBox();
                    }
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user['full_name'][0].toUpperCase()),
                      ),
                      title: Text(
                        user['full_name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: button,
                    ),
                  );
                },
              );
            },
          );
        }
      ),
    );
  }
}