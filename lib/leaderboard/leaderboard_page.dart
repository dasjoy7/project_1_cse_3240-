import 'package:flutter/material.dart';
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

  // Filter values
  String selectedCategory = 'All';
  String selectedDivision = 'All';
  String selectedDistrict = 'All';

  // Available filter options
  List<String> categories = ['All', 'Junior', 'Secondary', 'Higher Sec'];
  List<String> divisions = ['All'];
  List<String> districts = ['All'];

  // Bangladesh divisions and districts mapping
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
        // Get current user's category
        final userProfile = await Supabase.instance.client
            .from('profile')
            .select('category')
            .eq('id', currentUserId!)
            .single();

        currentUserCategory = userProfile['category'];
        selectedCategory = currentUserCategory ?? 'All';
      }

      // Fetch all unique divisions and districts
      await _loadFilterOptions();
      await _loadLeaderboard();
    } catch (e) {
      print('Error initializing filters: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadFilterOptions() async {
    // Use predefined divisions
    setState(() {
      divisions = ['All', ..._locations.keys.toList()];

      // Initially show all districts from all divisions
      Set<String> allDistricts = {'All'};
      for (var districtList in _locations.values) {
        allDistricts.addAll(districtList);
      }
      districts = allDistricts.toList()..sort();
    });
  }

  void _updateDistrictsForDivision(String division) {
    setState(() {
      if (division == 'All') {
        // Show all districts
        Set<String> allDistricts = {'All'};
        for (var districtList in _locations.values) {
          allDistricts.addAll(districtList);
        }
        districts = allDistricts.toList()..sort();
        selectedDistrict = 'All';
      } else {
        // Show only districts for selected division
        districts = ['All', ...(_locations[division] ?? [])];

        // Reset district selection if current selection is not in new list
        if (!districts.contains(selectedDistrict)) {
          selectedDistrict = 'All';
        }
      }
    });
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Build query with filters
      var query = Supabase.instance.client
          .from('profile')
          .select('id, username, full_name, institution, category, division, district, rating, student_class');

      // Apply filters
      if (selectedCategory != 'All') {
        query = query.eq('category', selectedCategory);
      }

      if (selectedDivision != 'All') {
        query = query.eq('division', selectedDivision);
      }

      if (selectedDistrict != 'All') {
        query = query.eq('district', selectedDistrict);
      }

      // Order by rating descending
      final response = await query.order('rating', ascending: false);

      setState(() {
        leaderboard = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading leaderboard: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showFilterDialog() {
    String tempCategory = selectedCategory;
    String tempDivision = selectedDivision;
    String tempDistrict = selectedDistrict;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Leaderboard'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: categories.map((category) {
                    return ChoiceChip(
                      label: Text(category),
                      selected: tempCategory == category,
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() {
                            tempCategory = category;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Division',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempDivision,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: divisions.map((division) {
                    return DropdownMenuItem(
                      value: division,
                      child: Text(division),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      tempDivision = value!;

                      // Update available districts based on selected division
                      if (tempDivision == 'All') {
                        Set<String> allDistricts = {'All'};
                        for (var districtList in _locations.values) {
                          allDistricts.addAll(districtList);
                        }
                        districts = allDistricts.toList()..sort();
                        tempDistrict = 'All';
                      } else {
                        districts = ['All', ...(_locations[tempDivision] ?? [])];

                        // Reset district if not in new list
                        if (!districts.contains(tempDistrict)) {
                          tempDistrict = 'All';
                        }
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'District',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempDistrict,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      tempDistrict = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
              child: const Text('Reset'),
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
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Count active filters
    int activeFilters = 0;
    if (selectedCategory != 'All') activeFilters++;
    if (selectedDivision != 'All') activeFilters++;
    if (selectedDistrict != 'All') activeFilters++;

    return Scaffold(
      appBar: AppBar(
        title: const Text('National Leaderboard'),
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
      body: Column(
        children: [
          // Active Filters Display
          if (activeFilters > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (selectedCategory != 'All')
                    Chip(
                      label: Text('Category: $selectedCategory'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedCategory = 'All';
                        });
                        _loadLeaderboard();
                      },
                    ),
                  if (selectedDivision != 'All')
                    Chip(
                      label: Text('Division: $selectedDivision'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedDivision = 'All';
                        });
                        _loadLeaderboard();
                      },
                    ),
                  if (selectedDistrict != 'All')
                    Chip(
                      label: Text('District: $selectedDistrict'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedDistrict = 'All';
                        });
                        _loadLeaderboard();
                      },
                    ),
                ],
              ),
            ),

          // Leaderboard List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : leaderboard.isEmpty
                ? const Center(
              child: Text(
                'No users found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                final username = entry['username'] ?? 'Unknown';
                final fullName = entry['full_name'] ?? 'Unknown';
                final institution = entry['institution'] ?? '';
                final rating = (entry['rating'] as num?)?.toInt() ?? 0;
                final userId = entry['id'];
                final category = entry['category'] ?? '';
                final division = entry['division'] ?? '';
                final district = entry['district'] ?? '';
                final studentClass = entry['student_class'] ?? 0;
                final isCurrentUser = userId == currentUserId;

                // Calculate rank considering ties
                int rank = 1;
                if (index > 0) {
                  final prevEntry = leaderboard[index - 1];
                  final prevRating = (prevEntry['rating'] as num?)?.toInt() ?? 0;

                  if (rating == prevRating) {
                    // Find the rank of the first person in this tie group
                    for (int i = index - 1; i >= 0; i--) {
                      final checkEntry = leaderboard[i];
                      final checkRating = (checkEntry['rating'] as num?)?.toInt() ?? 0;

                      if (checkRating == rating) {
                        rank = i + 1;
                      } else {
                        break;
                      }
                    }
                  } else {
                    rank = index + 1;
                  }
                }

                // Medal colors for top 3
                Color? rankColor;
                IconData? medalIcon;
                if (rank == 1) {
                  rankColor = Colors.amber;
                  medalIcon = Icons.emoji_events;
                } else if (rank == 2) {
                  rankColor = Colors.grey[400];
                  medalIcon = Icons.emoji_events;
                } else if (rank == 3) {
                  rankColor = Colors.brown[300];
                  medalIcon = Icons.emoji_events;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isCurrentUser ? 4 : 1,
                  color: isCurrentUser ? Colors.blue.shade50 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isCurrentUser
                        ? BorderSide(color: Colors.blue, width: 2)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Rank
                        SizedBox(
                          width: 50,
                          child: Column(
                            children: [
                              if (medalIcon != null)
                                Icon(medalIcon, color: rankColor, size: 32)
                              else
                                Text(
                                  '#$rank',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      fullName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrentUser
                                            ? Colors.blue.shade900
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (isCurrentUser)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'You',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@$username',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (institution.isNotEmpty)
                                Text(
                                  institution,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _buildInfoChip(
                                    label: category,
                                    color: Colors.purple,
                                  ),
                                  _buildInfoChip(
                                    label: 'Class $studentClass',
                                    color: Colors.teal,
                                  ),
                                  if (division.isNotEmpty)
                                    _buildInfoChip(
                                      label: division,
                                      color: Colors.indigo,
                                    ),
                                  if (district.isNotEmpty)
                                    _buildInfoChip(
                                      label: district,
                                      color: Colors.cyan,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Rating
                        Column(
                          children: [
                            Text(
                              '$rating',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: rating >= 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                            Text(
                              'points',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}