import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/individual_profile_page.dart';
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
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _friends = [];
  bool _searchLoading = false;
  bool _friendsLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    setState(() => _friendsLoading = true);
    final currentUserId = _client.auth.currentUser!.id;

    final friendships = await _client
        .from('friendships')
        .select()
        .eq('status', 'accepted')
        .or('requester_id.eq.$currentUserId,receiver_id.eq.$currentUserId');

    final friendIds = friendships.map<String>((f) {
      return f['requester_id'] == currentUserId
          ? f['receiver_id'] as String
          : f['requester_id'] as String;
    }).toList();

    if (friendIds.isEmpty) {
      setState(() {
        _friends = [];
        _friendsLoading = false;
      });
      return;
    }

    final profiles = await _client
        .from('profile')
        .select()
        .inFilter('id', friendIds);

    setState(() {
      _friends = List<Map<String, dynamic>>.from(profiles);
      _friendsLoading = false;
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchLoading = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchLoading = true;
    });

    final currentUserId = _client.auth.currentUser!.id;

    final results = await _client
        .from('profile')
        .select()
        .neq('id', currentUserId)
        .ilike('full_name', '%${query.trim()}%');

    if (mounted) {
      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(results);
        _searchLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Find Friends"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search users by name...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchUsers('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchUsers,
            ),
          ),

          // ── Search Results ──
          if (_isSearching) ...[
            if (_searchLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_searchResults.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("No users found",
                      style: TextStyle(fontSize: 15, color: Colors.grey)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return _UserTile(
                      user: user,
                      friendService: _friendService,
                      onTap: () => _goToProfile(user['id']),
                      onFriendshipChanged: _fetchFriends,
                    );
                  },
                ),
              ),
          ]

          // ── Friends List ──
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  const Text(
                    "My Friends",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5)),
                  ),
                  const SizedBox(width: 8),
                  if (!_friendsLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_friends.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            if (_friendsLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_friends.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("No friends yet",
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text("Search for users above to add friends",
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchFriends,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final user = _friends[index];
                      return _FriendTile(
                        user: user,
                        onTap: () => _goToProfile(user['id']),
                        onChat: () => _goToChat(user),
                      );
                    },
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _goToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IndividualProfilePage(userId: userId),
      ),
    );
  }

  void _goToChat(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          receiverId: user['id'],
          receiverName: user['full_name'],
        ),
      ),
    );
  }
}

// ── Search result tile with friend action button ──
class _UserTile extends StatefulWidget {
  final Map<String, dynamic> user;
  final FriendService friendService;
  final VoidCallback onTap;
  final VoidCallback onFriendshipChanged;

  const _UserTile({
    required this.user,
    required this.friendService,
    required this.onTap,
    required this.onFriendshipChanged,
  });

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile> {
  Map<String, dynamic>? _friendship;
  bool _loading = true;
  final _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadFriendship();
  }

  Future<void> _loadFriendship() async {
    setState(() => _loading = true);
    final data = await widget.friendService.getFriendship(widget.user['id']);
    if (mounted) {
      setState(() {
        _friendship = data;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadFriendship();
    widget.onFriendshipChanged();
  }

  Widget _buildButton() {
    if (_loading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final currentUserId = _client.auth.currentUser!.id;
    final status = _friendship?['status'];

    if (status == 'accepted') {
      return const Icon(Icons.people, color: Colors.green);
    }

    if (status == 'pending') {
      final isRequester = _friendship?['requester_id'] == currentUserId;
      if (isRequester) {
        return TextButton(
          onPressed: () async {
            await widget.friendService.removeRequest(_friendship!['id']);
            _refresh();
          },
          child: const Text("Pending", style: TextStyle(color: Colors.orange)),
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () async {
                await widget.friendService.acceptRequest(_friendship!['id']);
                _refresh();
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () async {
                await widget.friendService.removeRequest(_friendship!['id']);
                _refresh();
              },
            ),
          ],
        );
      }
    }

    return IconButton(
      icon: const Icon(Icons.person_add_alt_1, color: Colors.blue),
      onPressed: () async {
        await widget.friendService.sendFriendRequest(widget.user['id']);
        _refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user['full_name'] ?? '';
    final username = widget.user['username'] ?? '';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: widget.onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1E88E5),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: username.isNotEmpty ? Text('@$username') : null,
        trailing: _buildButton(),
      ),
    );
  }
}

// ── Friend tile with chat button (no need to fetch friendship) ──
class _FriendTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;
  final VoidCallback onChat;

  const _FriendTile({
    required this.user,
    required this.onTap,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final name = user['full_name'] ?? '';
    final username = user['username'] ?? '';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1E88E5),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: username.isNotEmpty ? Text('@$username') : null,
        trailing: IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
          onPressed: onChat,
        ),
      ),
    );
  }
}