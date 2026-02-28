import 'package:flutter/material.dart';
import 'problem_card.dart';
import 'problem_controller.dart';
import 'problem_detail_page.dart';
import 'problem_model.dart';

// ── Theme constants ────────────────────────────────────────────────────────
const _kPrimary    = Color(0xFF4A90D9);
const _kPrimaryDeep= Color(0xFF3574C4);
const _kSurface    = Color(0xFFF7F9FC);
const _kCardWhite  = Color(0xFFFFFFFF);
const _kTextDark   = Color(0xFF1E2A3B);
const _kTextMid    = Color(0xFF5A6A7E);
const _kTextLight  = Color(0xFF8FA0B4);
const _kBorder     = Color(0xFFEAEFF6);
// ───────────────────────────────────────────────────────────────────────────

class ProblemPage extends StatefulWidget {
  const ProblemPage({super.key});

  @override
  State<ProblemPage> createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProblemController _controller = ProblemController();

  final List<String> _categories   = ['Mathematical', 'Logical', 'Puzzle'];
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
    _controller.removeListener(_onControllerUpdate);
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
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: _kCardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
                          'Filter Problems',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _kTextDark,
                          ),
                        ),
                        const Spacer(),
                        if (_controller.hasActiveFilter)
                          GestureDetector(
                            onTap: () {
                              _controller.clearFilters();
                              setSheetState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: _kPrimary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Clear All',
                                style: TextStyle(
                                  color: _kPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Difficulty section
                    const Text(
                      'DIFFICULTY',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: _kTextLight,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _controller.selectedDifficulty == null,
                          color: _kTextMid,
                          onTap: () {
                            _controller.setDifficulty(null);
                            setSheetState(() {});
                          },
                        ),
                        ..._difficulties.map((d) {
                          final color = d == 'Easy'
                              ? const Color(0xFF3DAA6E)
                              : d == 'Medium'
                                  ? const Color(0xFFE89B2A)
                                  : const Color(0xFFE05555);
                          return _FilterChip(
                            label: d,
                            selected: _controller.selectedDifficulty
                                    ?.toLowerCase() ==
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

                    // Sub-category section
                    const Text(
                      'SUB CATEGORY',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: _kTextLight,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (subCategories.isEmpty)
                      Text(
                        'No sub-categories available.',
                        style: TextStyle(color: _kTextLight, fontSize: 13),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected:
                                _controller.selectedSubCategory == null,
                            color: _kTextMid,
                            onTap: () {
                              _controller.setSubCategory(null);
                              setSheetState(() {});
                            },
                          ),
                          ...subCategories.map((s) => _FilterChip(
                                label: s,
                                selected:
                                    _controller.selectedSubCategory == s,
                                color: _kPrimary,
                                onTap: () {
                                  _controller.setSubCategory(s);
                                  setSheetState(() {});
                                },
                              )),
                        ],
                      ),
                    const SizedBox(height: 28),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProblemList(String category) {
    if (_controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: _kPrimary,
          strokeWidth: 2.5,
        ),
      );
    }
    if (_controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE05555).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 40, color: Color(0xFFE05555)),
            ),
            const SizedBox(height: 16),
            Text(
              _controller.error!,
              style: const TextStyle(color: _kTextMid, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.fetchProblems,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 48, color: _kPrimary.withOpacity(0.5)),
            ),
            const SizedBox(height: 16),
            Text(
              _controller.hasActiveFilter
                  ? 'No problems match the selected filters.'
                  : 'No $category problems yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kTextMid, fontSize: 15),
            ),
            if (_controller.hasActiveFilter) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _controller.clearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Clear Filters',
                    style: TextStyle(
                      color: _kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _kPrimary,
      onRefresh: _controller.fetchProblems,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
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
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kCardWhite,
        foregroundColor: _kTextDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Problems',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            color: _kTextDark,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: activeFilterCount > 0
                        ? _kPrimary.withOpacity(0.09)
                        : _kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      color: activeFilterCount > 0 ? _kPrimary : _kTextMid,
                    ),
                    tooltip: 'Filter',
                    onPressed: _showFilterSheet,
                  ),
                ),
                if (activeFilterCount > 0)
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
                          '$activeFilterCount',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(height: 1, color: _kBorder),
              TabBar(
                controller: _tabController,
                indicatorColor: _kPrimary,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: _kPrimary,
                unselectedLabelColor: _kTextLight,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: _categories.map((c) => Tab(text: c)).toList(),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Active filter banner
          if (_controller.hasActiveFilter)
            Container(
              color: _kPrimary.withOpacity(0.06),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded,
                      size: 15, color: _kPrimary),
                  const SizedBox(width: 6),
                  const Text(
                    'Filtered: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: _kTextMid,
                      fontWeight: FontWeight.w500,
                    ),
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
                        fontSize: 12,
                        color: _kPrimary,
                        fontWeight: FontWeight.w700,
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

// ── Reusable widgets ──────────────────────────────────────────────────────────

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
          color: selected ? color : color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : color.withOpacity(0.25),
            width: 1,
          ),
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
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}