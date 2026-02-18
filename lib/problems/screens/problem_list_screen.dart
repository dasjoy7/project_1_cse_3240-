import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/problems/theme/app_colors.dart';
import 'package:project_1_cse_3240/problems/widgets/problem_card.dart';
import 'package:project_1_cse_3240/problems/model/problem.dart';
import 'package:project_1_cse_3240/problems/services/supabase_service.dart';

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
  String selectedTag = 'All';

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
        title: Text('Problems'),
        actions: [
          IconButton(
            icon: Icon(isGrid?Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGrid = !isGrid;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FBFF), Color(0xFFE3F2FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _topTabs(),
            _searchBar(),
            _difficultyChips(),
            Expanded(child: _problemBody()),
          ],
        ),
      ),
    );
  }

  Widget _problemBody() {
    return FutureBuilder<List<Problem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final allProblems = snapshot.data ?? [];

        if (allProblems.isEmpty) {
          return Center(child: Text('No problems found'));
        }

        final Set<String> tagSet = {};
        for (var p in allProblems) {
          tagSet.addAll(p.tags);
        }

        final tags = tagSet.toList()..sort();

        final filteredProblems = selectedTag == 'All'
            ? allProblems
            : allProblems
            .where((p) => p.tags.contains(selectedTag))
            .toList();

        return Column(
          children: [
            _filterHeader(tags),
            Expanded(
              child: isGrid
                  ? GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: .01,
                  mainAxisSpacing: .01,
                  childAspectRatio: .6,
                ),
                itemCount: filteredProblems.length,
                itemBuilder: (_, i) =>
                    ProblemCard(problem: filteredProblems[i]),
              )
                  : ListView.builder(
                itemCount: filteredProblems.length,
                itemBuilder: (_, i) =>
                    ProblemCard(problem: filteredProblems[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterHeader(List<String> tags) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose from filter",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 6),
          GestureDetector(
            onTap: () => _openFilterSheet(tags),
            child: Container(
              padding:
              EdgeInsets.symmetric(horizontal: 14,vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedTag,
                    style: TextStyle(fontWeight: FontWeight.w500,),
                  ),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterSheet(List<String> tags) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _bottomTagChip('All'),
              ...tags.map((tag) => _bottomTagChip(tag)),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomTagChip(String tag) {
    final isSelected = selectedTag == tag;

    return ChoiceChip(
      label: Text(tag),
      selected: isSelected,
      selectedColor: primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
      onSelected: (_) {
        setState(() {
          selectedTag = tag;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _topTabs() {
    final tabs = ['Mathematical', 'Logical', 'Puzzle'];

    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((t) {
          final selected = category == t;
          return ChoiceChip(
            label: Text(t,
              style: TextStyle(color: selected ? Colors.white : primaryBlue,fontWeight: FontWeight.w600,),
            ),
            selected: selected,
            selectedColor: primaryBlue,
            backgroundColor: Colors.grey.shade200,
            onSelected: (_) {
              setState(() {
                category = t;
                selectedTag = 'All';
                _load();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search problems...',
          prefixIcon: Icon(Icons.search, color: primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onChanged: (v) {
          setState(() {
            search = v;
            selectedTag = 'All';
            _load();
          });
        },
      ),
    );
  }

  Widget _difficultyChips() {
    final levels = ['All','Easy','Medium','Hard'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: levels.map((level) {
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(level),
              selected: difficulty == level,
              onSelected: (_) {
                setState(() {
                  difficulty = level;
                  selectedTag = 'All';
                  _load();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:project_1/problems_and_profile/problems/theme/app_colors.dart';
import 'package:project_1/problems_and_profile/problems/widgets/problem_card.dart';
import 'package:project_1/problems_and_profile/problems/models/problem.dart';
import 'package:project_1/problems_and_profile/problems/services/supabase_service.dart';
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
  bool isGrid =false;
  late Future<List<Problem>>future;

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FBFF), Color(0xFFE3F2FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          children: [
            _topTabs(),
            _searchBar(),
            _difficultyChips(),
            Expanded(child: _problemBody()),
          ],
        ),
      ),

      backgroundColor: bgColor,
      appBar: AppBar(
        title:Text('Problems'),
        actions: [
          IconButton(
            icon: Icon(isGrid?Icons.list:Icons.grid_view),
            onPressed: () {
              setState(()=>isGrid=!isGrid);
            },
          ),
        ],
      ),
    );
  }

  // ================= BODY =================
  Widget _problemBody() {
    return FutureBuilder<List<Problem>>(
      future: future,
      builder: (context,snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting)
        {
          return Center(child: CircularProgressIndicator());
        }
        if(snapshot.hasError)
        {
          return Center(child: Text(snapshot.error.toString()));
        }
        final problems=snapshot.data!;
        if (problems.isEmpty)
        {
          return Center(child: Text('No problems found'));
        }
        if(isGrid)
        {
          return GridView.builder(
            padding: EdgeInsets.all(0),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing:.01,
              mainAxisSpacing:.01,
              childAspectRatio: 0.85,
            ),
            itemCount: problems.length,
            itemBuilder: (_,i)=>ProblemCard(problem:problems[i]),
          );
        }
        return ListView.builder(
          itemCount: problems.length,
          itemBuilder: (_,i)=>ProblemCard(problem:problems[i]),
        );
      },
    );
  }

  // ================= UI PARTS =================
  Widget _topTabs() {
    final tabs=['Mathematical','Logical','Puzzle'];
    return Padding(
      padding:EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((t) {
          final selected=category==t;
          return ChoiceChip(
            label: Text(t,style: TextStyle(
                color: selected?Colors.white:primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: selected,
            selectedColor: primaryBlue,
            backgroundColor: Colors.grey.shade200,
            onSelected: (_){category=t;_load();setState(() {});
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search problems...',
          prefixIcon: Icon(Icons.search,color:primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            //borderSide: BorderSide.none,
          ),
        ),
        onChanged: (v){search=v;
          _load();
          setState(() {});
        },
      ),
    );
  }

  Widget _difficultyChips() {
    final levels = ['All','Easy','Medium','Hard'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:12),
      child: Row(
        children: levels.map((level) {
          return Padding(
            padding: EdgeInsets.only(right:8),
            child: ChoiceChip(
              label: Text(level),
              selected: difficulty==level,
              onSelected: (_){difficulty=level;
                _load();
                setState(() {});
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}*/