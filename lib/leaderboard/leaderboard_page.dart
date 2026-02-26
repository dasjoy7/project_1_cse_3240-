import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/individual_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> leaderboard = [];
  bool isLoading = true;
  String? currentUserId;
  String? currentUserCategory;

  String selectedCategory = 'All';
  String selectedDivision = 'All';
  String selectedDistrict = 'All';

  List<String> categories = ['All', 'Junior', 'Secondary', 'Higher Sec'];
  List<String> divisions = ['All'];
  List<String> districts = ['All'];

  final Map<String, List<String>> _locations = {
    'Barishal': [
      'Barguna',
      'Barishal',
      'Bhola',
      'Jhalokati',
      'Patuakhali',
      'Pirojpur',
    ],
    'Chattogram': [
      'Bandarban',
      'Brahmanbaria',
      'Chandpur',
      'Chattogram',
      'Cumilla',
      "Cox's Bazar",
      'Feni',
      'Khagrachari',
      'Lakshmipur',
      'Noakhali',
      'Rangamati',
    ],
    'Dhaka': [
      'Dhaka',
      'Faridpur',
      'Gazipur',
      'Gopalganj',
      'Kishoreganj',
      'Madaripur',
      'Manikganj',
      'Munshiganj',
      'Narayanganj',
      'Narsingdi',
      'Rajbari',
      'Shariatpur',
      'Tangail',
    ],
    'Khulna': [
      'Bagerhat',
      'Chuadanga',
      'Jashore',
      'Jhenaidah',
      'Khulna',
      'Kushtia',
      'Magura',
      'Meherpur',
      'Narail',
      'Satkhira',
    ],
    'Mymensingh': ['Jamalpur', 'Mymensingh', 'Netrokona', 'Sherpur'],
    'Rajshahi': [
      'Bogura',
      'Joypurhat',
      'Naogaon',
      'Natore',
      'Chapainawabganj',
      'Pabna',
      'Rajshahi',
      'Sirajganj',
    ],
    'Rangpur': [
      'Dinajpur',
      'Gaibandha',
      'Kurigram',
      'Lalmonirhat',
      'Nilphamari',
      'Panchagarh',
      'Rangpur',
      'Thakurgaon',
    ],
    'Sylhet': ['Habiganj', 'Moulvibazar', 'Sunamganj', 'Sylhet'],
  };

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  Future<void> _initializeFilters() async {
    try {
      currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId != null) {
        final userProfile = await Supabase.instance.client
            .from('profile')
            .select('category')
            .eq('id', currentUserId!)
            .single();
        currentUserCategory = userProfile['category'];
        selectedCategory = currentUserCategory ?? 'All';
      }
      await _loadFilterOptions();
      await _loadLeaderboard();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadFilterOptions() async {
    setState(() {
      divisions = ['All', ..._locations.keys.toList()];
      Set<String> allDistricts = {'All'};
      for (var districtList in _locations.values) {
        allDistricts.addAll(districtList);
      }
      districts = allDistricts.toList()..sort();
    });
  }

  Future<void> _loadLeaderboard() async {
    setState(() => isLoading = true);
    try {
      var query = Supabase.instance.client
          .from('profile')
          .select(
            'id, username, full_name, institution, category, division, district, rating, student_class',
          );

      if (selectedCategory != 'All')
        query = query.eq('category', selectedCategory);
      if (selectedDivision != 'All')
        query = query.eq('division', selectedDivision);
      if (selectedDistrict != 'All')
        query = query.eq('district', selectedDistrict);

      final response = await query.order('rating', ascending: false);
      setState(() {
        leaderboard = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndividualProfilePage(userId: userId),
      ),
    );
  }

  void _showFilterDialog() {
    String tempCategory = selectedCategory;
    String tempDivision = selectedDivision;
    String tempDistrict = selectedDistrict;
    List<String> tempDistricts = List.from(districts);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Filter Leaderboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: categories.map((category) {
                    return ChoiceChip(
                      label: Text(category),
                      selected: tempCategory == category,
                      selectedColor: const Color(0xFF1E88E5).withOpacity(0.2),
                      onSelected: (selected) {
                        if (selected)
                          setDialogState(() => tempCategory = category);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Division',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempDivision,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: divisions
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      tempDivision = value!;
                      if (tempDivision == 'All') {
                        Set<String> all = {'All'};
                        for (var list in _locations.values) all.addAll(list);
                        tempDistricts = all.toList()..sort();
                        tempDistrict = 'All';
                      } else {
                        tempDistricts = [
                          'All',
                          ...(_locations[tempDivision] ?? []),
                        ];
                        if (!tempDistricts.contains(tempDistrict))
                          tempDistrict = 'All';
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'District',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempDistrict,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: tempDistricts
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => tempDistrict = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory = 'All';
                  selectedDivision = 'All';
                  selectedDistrict = 'All';
                });
                _loadLeaderboard();
                Navigator.pop(context);
              },
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCategory = tempCategory;
                  selectedDivision = tempDivision;
                  selectedDistrict = tempDistrict;
                });
                _loadLeaderboard();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Podium: Top 3 horizontal layout ──
  Widget _buildPodium() {
    if (leaderboard.isEmpty) return const SizedBox.shrink();

    final top = leaderboard.take(3).toList();
    // Reorder: 2nd, 1st, 3rd for visual podium effect
    final ordered = [
      if (top.length > 1) top[1], // 2nd — left
      top[0], // 1st — center
      if (top.length > 2) top[2], // 3rd — right
    ];
    final positions = top.length > 1
        ? (top.length > 2 ? [2, 1, 3] : [2, 1])
        : [1];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(ordered.length, (i) {
          final entry = ordered[i];
          final rank = positions[i];
          final isFirst = rank == 1;
          final userId = entry['id'];
          final isCurrentUser = userId == currentUserId;

          return GestureDetector(
            onTap: () => _navigateToProfile(userId),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crown for 1st
                if (isFirst)
                  const Text('👑', style: TextStyle(fontSize: 22))
                else
                  const SizedBox(height: 22),

                const SizedBox(height: 4),

                // Avatar
                Container(
                  width: isFirst ? 72 : 58,
                  height: isFirst ? 72 : 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: _medalColor(rank),
                      width: isFirst ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _medalColor(rank).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (entry['full_name'] ?? '?')[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isFirst ? 28 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Medal badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _medalColor(rank),
                    boxShadow: [
                      BoxShadow(
                        color: _medalColor(rank).withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Name
                SizedBox(
                  width: isFirst ? 90 : 74,
                  child: Text(
                    entry['full_name'] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                      fontSize: isFirst ? 13 : 11,
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                // Rating
                Text(
                  '${entry['rating'] ?? 0} pts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: isFirst ? 12 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (isCurrentUser) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'You',
                      style: TextStyle(
                        color: Color(0xFF1E88E5),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                // Podium base
                const SizedBox(height: 8),
                Container(
                  width: isFirst ? 80 : 64,
                  height: isFirst ? 36 : 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Color _medalColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    return const Color(0xFFCD7F32);
  }

  // ── Single rank card (4th onwards) ──
  Widget _buildRankCard(Map<String, dynamic> entry, int rank) {
    final isCurrentUser = entry['id'] == currentUserId;
    final fullName = entry['full_name'] ?? 'Unknown';
    final username = entry['username'] ?? '';
    final rating = (entry['rating'] as num?)?.toInt() ?? 0;

    return GestureDetector(
      onTap: () => _navigateToProfile(entry['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? const Color(0xFFE3F2FD) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isCurrentUser
              ? Border.all(color: const Color(0xFF1E88E5), width: 1.5)
              : Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isCurrentUser ? 0.08 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 36,
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey.shade500,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF1E88E5).withOpacity(0.12),
              child: Text(
                fullName[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name + username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E88E5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '@$username',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Rating
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$rating',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: rating > 0 ? Colors.green.shade700 : Colors.grey,
                  ),
                ),
                Text(
                  'pts',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int activeFilters = 0;
    if (selectedCategory != 'All') activeFilters++;
    if (selectedDivision != 'All') activeFilters++;
    if (selectedDistrict != 'All') activeFilters++;

    final restOfList = leaderboard.length > 3 ? leaderboard.sublist(3) : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              if (activeFilters > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeFilters',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : leaderboard.isEmpty
          ? const Center(
              child: Text(
                'No users found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                // Active filter chips
                if (activeFilters > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: Colors.blue.shade50,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (selectedCategory != 'All')
                          Chip(
                            label: Text('Category: $selectedCategory'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() => selectedCategory = 'All');
                              _loadLeaderboard();
                            },
                          ),
                        if (selectedDivision != 'All')
                          Chip(
                            label: Text('Division: $selectedDivision'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() => selectedDivision = 'All');
                              _loadLeaderboard();
                            },
                          ),
                        if (selectedDistrict != 'All')
                          Chip(
                            label: Text('District: $selectedDistrict'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() => selectedDistrict = 'All');
                              _loadLeaderboard();
                            },
                          ),
                      ],
                    ),
                  ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      // Top 3 podium
                      if (leaderboard.isNotEmpty) _buildPodium(),

                      // 4th onwards
                      if (restOfList.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  'Rankings',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                            ],
                          ),
                        ),
                        ...restOfList.asMap().entries.map((e) {
                          return _buildRankCard(
                            e.value as Map<String, dynamic>,
                            e.key + 4,
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
