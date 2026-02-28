import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'friend_service.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final _client = Supabase.instance.client;
  final FriendService _friendService = FriendService();

  @override
  Widget build(BuildContext context) {
    final currentUser = _client.auth.currentUser!;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: Text("Friend Requests"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _client
            .from('friendships')
            .select()
            .eq('status', 'pending')
            .eq('receiver_id', currentUser.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data as List;

          if (requests.isEmpty) {
            return Center(
              child: Text(
                "No Friend Requests",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    "Requester ID: ${req['requester_id']}",
                    style:TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: Icon(Icons.check, color: Colors.white),
                          onPressed: () async {
                            await _friendService.acceptRequest(req['id']);
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon:Icon(Icons.close, color: Colors.white),
                          onPressed: () async {
                            await _friendService.removeRequest(req['id']);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}