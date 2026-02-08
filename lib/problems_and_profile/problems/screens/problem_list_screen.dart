import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/problems_and_profile/problems/theme/app_colors.dart';
import 'package:project_1_cse_3240/problems_and_profile/problems/widgets/problem_card.dart';
import 'package:project_1_cse_3240/problems_and_profile/problems/model/problem.dart';
import '../services/supabase_service.dart';
class ProblemListPage extends StatefulWidget {
  const ProblemListPage({super.key});

  @override
  State<ProblemListPage> createState() => _ProblemListPageState();
}

class _ProblemListPageState extends State<ProblemListPage> {
  final SupabaseService service = SupabaseService();

  String category = 'Mathematical';
  String difficulty = 'All';
  String search = '';

  bool isGrid = false;

  late Future<List<Problem>> future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    future = service.fetchProblems(
      category: category,
      difficulty: difficulty,
      search: search,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Problems'),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() => isGrid = !isGrid);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _topTabs(),
          _searchBar(),
          _difficultyChips(),
          Expanded(child: _problemBody()),
        ],
      ),
    );
  }

  // ================= BODY =================

  Widget _problemBody() {
    return FutureBuilder<List<Problem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final problems = snapshot.data!;

        if (problems.isEmpty) {
          return Center(child: Text('No problems found'));
        }
        if (isGrid) {
          return GridView.builder(
            padding: EdgeInsets.all(2),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing:1,
              mainAxisSpacing:1,
              childAspectRatio: 1.35,
            ),
            itemCount: problems.length,
            itemBuilder: (_, i) =>
                ProblemCard(problem: problems[i]),
          );
        }

        return ListView.builder(
          itemCount: problems.length,
          itemBuilder: (_, i) =>
              ProblemCard(problem: problems[i]),
        );
      },
    );
  }

  // ================= UI PARTS =================

  Widget _topTabs() {
    final tabs = ['Mathematical', 'Logical', 'Puzzle'];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((t) {
          final selected = category == t;
          return ChoiceChip(
            label: Text(
              t,
              style: TextStyle(
                color: selected ? Colors.white : primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: selected,
            selectedColor: primaryBlue,
            backgroundColor: Colors.grey.shade200,
            onSelected: (_) {
              category = t;
              _load();
              setState(() {});
            },
          );

          /*return ChoiceChip(
            label: Text(t),
            selected: selected,
            onSelected: (_) {
              category = t;
              _load();
              setState(() {});
            },
          );*/
        }).toList(),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(

        decoration: InputDecoration(
          hintText: 'Search problems...',
          prefixIcon: Icon(Icons.search, color: primaryBlue),
          filled: true,
          fillColor: Colors.white60,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),

        onChanged: (v) {
          search = v;
          _load();
          setState(() {});
        },
      ),
    );
  }

  Widget _difficultyChips() {
    final levels = ['All', 'Easy', 'Medium', 'Hard'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: levels.map((level) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(level),
              selected: difficulty == level,
              onSelected: (_) {
                difficulty = level;
                _load();
                setState(() {});
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}