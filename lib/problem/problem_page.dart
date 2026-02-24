import 'package:flutter/material.dart';
import 'problem_card.dart';
import 'problem_controller.dart';
import 'problem_detail_page.dart';
import 'problem_model.dart';

class ProblemPage extends StatefulWidget {
  const ProblemPage({super.key});

  @override
  State<ProblemPage> createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProblemController _controller = ProblemController(); // gets singleton

  final List<String> _categories = ['Mathematical', 'Logical', 'Puzzle'];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _controller.setSubCategory(null);
      }
    });
    _controller.init();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.removeListener(_onControllerUpdate); // ✅ only remove listener
    // ❌ do NOT call _controller.dispose()
    super.dispose();
  }

  void _openProblem(ProblemModel problem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProblemDetailPage(
          problem: problem,
          controller: _controller,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _showFilterSheet() {
    final currentCategory = _categories[_tabController.index];
    final subCategories = _controller.subCategoriesFor(currentCategory);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Filter Problems',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (_controller.hasActiveFilter)
                        TextButton(
                          onPressed: () {
                            _controller.clearFilters();
                            setSheetState(() {});
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Difficulty',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _controller.selectedDifficulty == null,
                        color: Colors.grey,
                        onTap: () {
                          _controller.setDifficulty(null);
                          setSheetState(() {});
                        },
                      ),
                      ..._difficulties.map((d) {
                        final color = d == 'Easy'
                            ? Colors.green
                            : d == 'Medium'
                            ? Colors.orange
                            : Colors.red;
                        return _FilterChip(
                          label: d,
                          selected:
                          _controller.selectedDifficulty?.toLowerCase() ==
                              d.toLowerCase(),
                          color: color,
                          onTap: () {
                            _controller.setDifficulty(d);
                            setSheetState(() {});
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sub Category',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  if (subCategories.isEmpty)
                    const Text(
                      'No sub-categories available.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _controller.selectedSubCategory == null,
                          color: Colors.blueGrey,
                          onTap: () {
                            _controller.setSubCategory(null);
                            setSheetState(() {});
                          },
                        ),
                        ...subCategories.map((s) => _FilterChip(
                          label: s,
                          selected: _controller.selectedSubCategory == s,
                          color: Colors.deepPurple,
                          onTap: () {
                            _controller.setSubCategory(s);
                            setSheetState(() {});
                          },
                        )),
                      ],
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                      const Text('Apply', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProblemList(String category) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_controller.error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _controller.fetchProblems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final problems = _controller.byCategory(category);

    if (problems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              _controller.hasActiveFilter
                  ? 'No problems match the selected filters.'
                  : 'No $category problems yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            if (_controller.hasActiveFilter) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _controller.clearFilters,
                child: const Text('Clear Filters',
                    style: TextStyle(color: Colors.deepPurple)),
              ),
            ]
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.fetchProblems,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        itemCount: problems.length,
        itemBuilder: (context, index) {
          return ProblemCard(
            problem: problems[index],
            onTap: () => _openProblem(problems[index]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilterCount = [
      _controller.selectedDifficulty,
      _controller.selectedSubCategory,
    ].where((f) => f != null).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Problems',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filter',
                onPressed: _showFilterSheet,
              ),
              if (activeFilterCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Column(
        children: [
          if (_controller.hasActiveFilter)
            Container(
              color: Colors.deepPurple.shade50,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.filter_list,
                      size: 16, color: Colors.deepPurple),
                  const SizedBox(width: 6),
                  const Text(
                    'Filtered by: ',
                    style: TextStyle(fontSize: 13, color: Colors.deepPurple),
                  ),
                  if (_controller.selectedDifficulty != null)
                    _ActiveFilterBadge(
                      label: _controller.selectedDifficulty!,
                      onRemove: () => _controller.setDifficulty(null),
                    ),
                  if (_controller.selectedSubCategory != null)
                    _ActiveFilterBadge(
                      label: _controller.selectedSubCategory!,
                      onRemove: () => _controller.setSubCategory(null),
                    ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _controller.clearFilters,
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
              _categories.map((c) => _buildProblemList(c)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border:
          Border.all(color: selected ? color : color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterBadge extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterBadge({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}