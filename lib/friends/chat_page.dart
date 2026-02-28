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
  final _supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final String _currentUserId;
  final List<Map<String, dynamic>> _messages = [];
  RealtimeChannel? _channel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser!.id;
    _init();
  }

  Future<void> _init() async {
    await _fetchMessages();
    _subscribeToMessages();
    await markMessagesAsDelivered();
    await markMessagesAsRead();
  }

  @override
  void dispose() {
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
    }
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ── Fetch all existing messages ──
  Future<void> _fetchMessages() async {
    final data = await _supabase
        .from('messages')
        .select()
        .or(
          'and(sender_id.eq.$_currentUserId,receiver_id.eq.${widget.receiverId}),'
          'and(sender_id.eq.${widget.receiverId},receiver_id.eq.$_currentUserId)',
        )
        .order('created_at', ascending: true);

    if (!mounted) return;
    setState(() {
      _messages.clear();
      _messages.addAll(List<Map<String, dynamic>>.from(data));
      _loading = false;
    });
    _scrollToBottom();
  }

  // ── Realtime: listen to ALL inserts/updates on messages table ──
  // We filter relevance client-side because Supabase Realtime
  // doesn't support OR filters on two different columns reliably.
  void _subscribeToMessages() {
    _channel = _supabase
        .channel('messages_${_currentUserId}_${widget.receiverId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final msg = Map<String, dynamic>.from(payload.newRecord);

            final bool isRelevant =
                (msg['sender_id'] == _currentUserId &&
                    msg['receiver_id'] == widget.receiverId) ||
                (msg['sender_id'] == widget.receiverId &&
                    msg['receiver_id'] == _currentUserId);

            if (!isRelevant || !mounted) return;

            // Avoid duplicate if we already added it optimistically
            final alreadyExists =
                _messages.any((m) => m['id'] == msg['id']);
            if (alreadyExists) return;

            setState(() => _messages.add(msg));
            _scrollToBottom();

            if (msg['sender_id'] == widget.receiverId) {
              markMessagesAsRead();
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            if (!mounted) return;
            final updated = Map<String, dynamic>.from(payload.newRecord);
            setState(() {
              final idx =
                  _messages.indexWhere((m) => m['id'] == updated['id']);
              if (idx != -1) _messages[idx] = updated;
            });
          },
        )
        .subscribe((status, [error]) {
          // Helpful for debugging — remove in production
          debugPrint('Realtime status: $status  error: $error');
        });
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    await _supabase.from('messages').insert({
      'sender_id': _currentUserId,
      'receiver_id': widget.receiverId,
      'message': text,
      'is_delivered': false,
      'is_read': false,
      'deleted_for_everyone': false,
    });
  }

  Future<void> markMessagesAsDelivered() async {
    await _supabase
        .from('messages')
        .update({'is_delivered': true})
        .eq('receiver_id', _currentUserId)
        .eq('sender_id', widget.receiverId)
        .eq('is_delivered', false);
  }

  Future<void> markMessagesAsRead() async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('receiver_id', _currentUserId)
        .eq('sender_id', widget.receiverId)
        .eq('is_read', false);
  }

  Future<void> _deleteForMe(String id) async {
    await _supabase.rpc('delete_for_me', params: {
      'message_id': id,
      'user_id': _currentUserId,
    });
  }

  Future<void> _deleteForEveryone(String id) async {
    await _supabase
        .from('messages')
        .update({'deleted_for_everyone': true})
        .eq('id', id);
  }

  String _formatTime(String utcTime) {
    final date = DateTime.parse(utcTime).toLocal();
    return DateFormat('hh:mm a').format(date);
  }

  Widget _buildTicks(Map<String, dynamic> msg) {
    if (msg['sender_id'] != _currentUserId) return const SizedBox();
    if (msg['is_read'] == true) {
      return const Icon(Icons.done_all, size: 15, color: Color(0xFF4FC3F7));
    } else if (msg['is_delivered'] == true) {
      return const Icon(Icons.done_all, size: 15, color: Colors.white54);
    } else {
      return const Icon(Icons.done, size: 15, color: Colors.white54);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1E88E5),
              child: Text(
                widget.receiverName.isNotEmpty
                    ? widget.receiverName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.receiverName,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          "No messages yet.\nSay hello! 👋",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white38, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg['sender_id'] == _currentUserId;

                          if ((msg['deleted_for'] ?? [])
                              .contains(_currentUserId)) {
                            return const SizedBox();
                          }

                          return _buildBubble(msg, isMe);
                        },
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg, bool isMe) {
    final isDeleted = msg['deleted_for_everyone'] == true;

    return GestureDetector(
      onLongPress: () {
        if (!isMe) return;
        _showDeleteSheet(msg['id']);
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFF1E88E5)
                : const Color(0xFF1C2333),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isDeleted)
                const Text(
                  "This message was deleted",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white54),
                )
              else
                Text(
                  msg['message'],
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : Colors.white.withOpacity(0.9),
                    fontSize: 14.5,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(msg['created_at']),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white38,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildTicks(msg),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(top: BorderSide(color: Color(0xFF1C2333))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2333),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.white38),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSheet(String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2333),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.white70),
              title: const Text("Delete for me",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await _deleteForMe(id);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Delete for everyone",
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _deleteForEveryone(id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}