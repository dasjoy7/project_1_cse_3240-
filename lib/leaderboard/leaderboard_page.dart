import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/individual_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Theme constants ────────────────────────────────────────────────────────
const _kPrimary     = Color(0xFF4A90D9);
const _kPrimaryDeep = Color(0xFF3574C4);
const _kSurface     = Color(0xFFF7F9FC);
const _kCardWhite   = Color(0xFFFFFFFF);
const _kTextDark    = Color(0xFF1E2A3B);
const _kTextMid     = Color(0xFF5A6A7E);
const _kTextLight   = Color(0xFF8FA0B4);
const _kBorder      = Color(0xFFEAEFF6);
// ───────────────────────────────────────────────────────────────────────────

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
    'Barishal': ['Barguna', 'Barishal', 'Bhola', 'Jhalokati', 'Patuakhali', 'Pirojpur'],
    'Chattogram': ['Bandarban', 'Brahmanbaria', 'Chandpur', 'Chattogram', 'Cumilla', "Cox's Bazar", 'Feni', 'Khagrachari', 'Lakshmipur', 'Noakhali', 'Rangamati'],
    'Dhaka': ['Dhaka', 'Faridpur', 'Gazipur', 'Gopalganj', 'Kishoreganj', 'Madaripur', 'Manikganj', 'Munshiganj', 'Narayanganj', 'Narsingdi', 'Rajbari', 'Shariatpur', 'Tangail'],
    'Khulna': ['Bagerhat', 'Chuadanga', 'Jashore', 'Jhenaidah', 'Khulna', 'Kushtia', 'Magura', 'Meherpur', 'Narail', 'Satkhira'],
    'Mymensingh': ['Jamalpur', 'Mymensingh', 'Netrokona', 'Sherpur'],
    'Rajshahi': ['Bogura', 'Joypurhat', 'Naogaon', 'Natore', 'Chapainawabganj', 'Pabna', 'Rajshahi', 'Sirajganj'],
    'Rangpur': ['Dinajpur', 'Gaibandha', 'Kurigram', 'Lalmonirhat', 'Nilphamari', 'Panchagarh', 'Rangpur', 'Thakurgaon'],
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
          .select('id, username, full_name, institution, category, division, district, rating, student_class');

      if (selectedCategory != 'All') query = query.eq('category', selectedCategory);
      if (selectedDivision != 'All') query = query.eq('division', selectedDivision);
      if (selectedDistrict != 'All') query = query.eq('district', selectedDistrict);

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
      MaterialPageRoute(builder: (context) => IndividualProfilePage(userId: userId)),
    );
  }

  void _showFilterDialog() {
    String tempCategory = selectedCategory;
    String tempDivision = selectedDivision;
    String tempDistrict = selectedDistrict;
    List<String> tempDistricts = List.from(districts);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: _kCardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _kBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Text(
                        'Filter Leaderboard',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _kTextDark,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = 'All';
                            selectedDivision = 'All';
                            selectedDistrict = 'All';
                          });
                          _loadLeaderboard();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE05555).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Color(0xFFE05555),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Category
                  const _SheetLabel(label: 'CATEGORY'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final selected = tempCategory == category;
                      return GestureDetector(
                        onTap: () => setSheetState(() => tempCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? _kPrimary : _kPrimary.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? _kPrimary : _kPrimary.withOpacity(0.25),
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: selected ? Colors.white : _kPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),

                  // Division
                  const _SheetLabel(label: 'DIVISION'),
                  const SizedBox(height: 10),
                  _StyledDropdown(
                    value: tempDivision,
                    items: divisions,
                    onChanged: (value) {
                      setSheetState(() {
                        tempDivision = value!;
                        if (tempDivision == 'All') {
                          Set<String> all = {'All'};
                          for (var list in _locations.values) all.addAll(list);
                          tempDistricts = all.toList()..sort();
                          tempDistrict = 'All';
                        } else {
                          tempDistricts = ['All', ...(_locations[tempDivision] ?? [])];
                          if (!tempDistricts.contains(tempDistrict)) tempDistrict = 'All';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 22),

                  // District
                  const _SheetLabel(label: 'DISTRICT'),
                  const SizedBox(height: 10),
                  _StyledDropdown(
                    value: tempDistrict,
                    items: tempDistricts,
                    onChanged: (value) => setSheetState(() => tempDistrict = value!),
                  ),
                  const SizedBox(height: 28),

                  // Apply
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
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
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Podium ────────────────────────────────────────────────────────────────
  Widget _buildPodium() {
    if (leaderboard.isEmpty) return const SizedBox.shrink();

    final top = leaderboard.take(3).toList();
    final ordered = [
      if (top.length > 1) top[1],
      top[0],
      if (top.length > 2) top[2],
    ];
    final positions = top.length > 1
        ? (top.length > 2 ? [2, 1, 3] : [2, 1])
        : [1];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimaryDeep, _kPrimary, Color(0xFF6EB3F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(color: _medalColor(rank), width: isFirst ? 3 : 2),
                    boxShadow: [
                      BoxShadow(
                        color: _medalColor(rank).withOpacity(0.4),
                        blurRadius: 10,
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
                  width: 26,
                  height: 26,
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
                        fontSize: 12,
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
                      fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
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
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'You',
                      style: TextStyle(
                        color: _kPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                // Podium base
                Container(
                  width: isFirst ? 80 : 64,
                  height: isFirst ? 36 : 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
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

  // ── Rank card (4th+) ──────────────────────────────────────────────────────
  Widget _buildRankCard(Map<String, dynamic> entry, int rank) {
    final isCurrentUser = entry['id'] == currentUserId;
    final fullName = entry['full_name'] ?? 'Unknown';
    final username = entry['username'] ?? '';
    final rating = (entry['rating'] as num?)?.toInt() ?? 0;

    return GestureDetector(
      onTap: () => _navigateToProfile(entry['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? _kPrimary.withOpacity(0.06) : _kCardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentUser ? _kPrimary.withOpacity(0.35) : _kBorder,
            width: isCurrentUser ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withOpacity(isCurrentUser ? 0.07 : 0.04),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _kTextLight,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  fullName[0].toUpperCase(),
                  style: const TextStyle(
                    color: _kPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                            color: _kTextDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _kPrimary,
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
                  const SizedBox(height: 2),
                  Text(
                    '@$username',
                    style: const TextStyle(color: _kTextLight, fontSize: 12),
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
                    fontWeight: FontWeight.w800,
                    color: rating > 0 ? const Color(0xFF3DAA6E) : _kTextLight,
                  ),
                ),
                const Text(
                  'pts',
                  style: TextStyle(fontSize: 11, color: _kTextLight),
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
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kCardWhite,
        foregroundColor: _kTextDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            color: _kTextDark,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          // Filter button
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: activeFilters > 0
                        ? _kPrimary.withOpacity(0.09)
                        : _kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.tune_rounded,
                        color: activeFilters > 0 ? _kPrimary : _kTextMid),
                    onPressed: _showFilterDialog,
                    tooltip: 'Filter',
                  ),
                ),
                if (activeFilters > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: _kPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$activeFilters',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Refresh button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorder),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, color: _kTextMid),
                onPressed: _loadLeaderboard,
                tooltip: 'Refresh',
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
            )
          : leaderboard.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _kPrimary.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.leaderboard_outlined,
                            size: 48, color: _kPrimary.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No users found',
                        style: TextStyle(fontSize: 15, color: _kTextMid),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Active filter chips banner
                    if (activeFilters > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: _kPrimary.withOpacity(0.06),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (selectedCategory != 'All')
                              _ActiveChip(
                                label: 'Category: $selectedCategory',
                                onRemove: () {
                                  setState(() => selectedCategory = 'All');
                                  _loadLeaderboard();
                                },
                              ),
                            if (selectedDivision != 'All')
                              _ActiveChip(
                                label: 'Division: $selectedDivision',
                                onRemove: () {
                                  setState(() => selectedDivision = 'All');
                                  _loadLeaderboard();
                                },
                              ),
                            if (selectedDistrict != 'All')
                              _ActiveChip(
                                label: 'District: $selectedDistrict',
                                onRemove: () {
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
                          if (leaderboard.isNotEmpty) _buildPodium(),

                          if (restOfList.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Divider(
                                          color: _kBorder, height: 1)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'RANKINGS',
                                      style: TextStyle(
                                        color: _kTextLight,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Divider(
                                          color: _kBorder, height: 1)),
                                ],
                              ),
                            ),
                            ...restOfList.asMap().entries.map((e) {
                              return _buildRankCard(
                                  e.value as Map<String, dynamic>, e.key + 4);
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

// ── Small reusable widgets ────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String label;
  const _SheetLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11,
        color: _kTextLight,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kTextMid),
          style: const TextStyle(color: _kTextDark, fontSize: 14),
          items: items
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}