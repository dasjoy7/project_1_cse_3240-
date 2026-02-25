import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = supabase.auth.currentUser!.id;

    markMessagesAsDelivered();
    markMessagesAsRead();
  }

  // SEND MESSAGE
  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    await supabase.from('messages').insert({
      'sender_id': currentUserId,
      'receiver_id': widget.receiverId,
      'message': text,
      'is_delivered': false,
      'is_read': false,
      'deleted_for_everyone': false,
    });
  }

  // MARK DELIVERED
  Future<void> markMessagesAsDelivered() async {
    await supabase
        .from('messages')
        .update({'is_delivered': true})
        .eq('receiver_id', currentUserId)
        .eq('sender_id', widget.receiverId)
        .eq('is_delivered', false);
  }

  // MARK READ
  Future<void> markMessagesAsRead() async {
    await supabase
        .from('messages')
        .update({'is_read': true})
        .eq('receiver_id', currentUserId)
        .eq('sender_id', widget.receiverId)
        .eq('is_read', false);
  }

  // DELETE FOR ME
  Future<void> deleteForMe(String id) async {
    await supabase.rpc('delete_for_me', params: {
      'message_id': id,
      'user_id': currentUserId,
    });
  }

  // DELETE FOR EVERYONE
  Future<void> deleteForEveryone(String id) async {
    await supabase
        .from('messages')
        .update({'deleted_for_everyone': true})
        .eq('id', id);
  }

  String formatTime(String utcTime) {
    final date = DateTime.parse(utcTime).toLocal();
    return DateFormat('hh:mm a').format(date);
  }

  Widget buildTicks(Map<String, dynamic> msg) {
    if (msg['sender_id'] != currentUserId) return const SizedBox();

    if (msg['is_read'] == true) {
      return const Icon(Icons.done_all, size: 18, color: Colors.blue);
    } else if (msg['is_delivered'] == true) {
      return const Icon(Icons.done_all, size: 18, color: Colors.grey);
    } else {
      return const Icon(Icons.done, size: 18, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEAE2),
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('messages')
                  .stream(primaryKey: ['id'])
                  .order('created_at')
                  .map((event) => event.where((m) {
                return (m['sender_id'] == currentUserId &&
                    m['receiver_id'] == widget.receiverId) ||
                    (m['sender_id'] == widget.receiverId &&
                        m['receiver_id'] == currentUserId);
              }).toList()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == currentUserId;

                    // HIDE MESSAGE IF DELETED FOR ME
                    if ((msg['deleted_for'] ?? [])
                        .contains(currentUserId)) {
                      return const SizedBox();
                    }

                    return GestureDetector(
                      onLongPress: () {
                        if (!isMe) return;

                        showModalBottomSheet(
                          context: context,
                          builder: (_) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading:
                                  const Icon(Icons.delete),
                                  title:
                                  const Text("Delete for me"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await deleteForMe(
                                        msg['id']);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                      Icons.delete_forever),
                                  title: const Text(
                                      "Delete for everyone"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await deleteForEveryone(
                                        msg['id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                              maxWidth:
                              MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.75),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFFF8C6C6)
                                : Colors.white,
                            borderRadius:
                            BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: [
                              if (msg['deleted_for_everyone'] ==
                                  true)
                                const Text(
                                  "This message was deleted",
                                  style: TextStyle(
                                      fontStyle:
                                      FontStyle.italic,
                                      color: Colors.grey),
                                )
                              else
                                Text(msg['message']),

                              const SizedBox(height: 4),

                              Row(
                                mainAxisSize:
                                MainAxisSize.min,
                                children: [
                                  Text(
                                    formatTime(
                                        msg['created_at']),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color:
                                        Colors.grey),
                                  ),
                                  const SizedBox(width: 5),
                                  buildTicks(msg),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      filled: true,
                      fillColor:
                      Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}