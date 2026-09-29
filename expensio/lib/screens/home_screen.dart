import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/empty_state.dart';
import 'add_edit_expense_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddExpense() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    final pages = [
      _ExpenseListPage(
        searchController: _searchController,
        showSearch: _showSearch,
        onAddExpense: _openAddExpense,
        onShowFilter: _showFilterSheet,
        onToggleSearch: () {
          setState(() {
            _showSearch = !_showSearch;
            if (!_showSearch) {
              _searchController.clear();
              provider.setSearchQuery('');
            }
          });
        },
      ),
      const AnalyticsScreen(),
      _ProfilePage(provider: provider),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: _openAddExpense,
                child: const Icon(Icons.add_rounded, size: 28),
              ).animate().scale(delay: 300.ms)
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ─── Expense List Page ────────────────────────────────────────────────────────

class _ExpenseListPage extends StatelessWidget {
  final TextEditingController searchController;
  final bool showSearch;
  final VoidCallback onAddExpense;
  final VoidCallback onShowFilter;
  final VoidCallback onToggleSearch;

  const _ExpenseListPage({
    required this.searchController,
    required this.showSearch,
    required this.onAddExpense,
    required this.onShowFilter,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expenses = provider.filteredExpenses;
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: AppTheme.background,
            floating: true,
            snap: true,
            expandedHeight: 0,
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  showSearch
                      ? TextField(
                        key: const ValueKey('search'),
                        controller: searchController,
                        autofocus: true,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        onChanged: provider.setSearchQuery,
                        decoration: const InputDecoration(
                          hintText: 'Search expenses...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                      : Text(
                        'Expensio',
                        key: const ValueKey('title'),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: AppTheme.textPrimary,
                        ),
                      ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  showSearch ? Icons.close_rounded : Icons.search_rounded,
                  color: AppTheme.textSecondary,
                ),
                onPressed: onToggleSearch,
              ),
              IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.textSecondary,
                ),
                onPressed: onShowFilter,
              ),
            ],
          ),

          // ── Summary Card ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SummaryCard(
                monthName: monthName,
                totalAmount: provider.thisMonthTotal,
                filteredAmount: provider.totalFilteredAmount,
                isFiltered: provider.selectedCategory != null ||
                    provider.filter != ExpenseFilter.thisMonth ||
                    provider.searchQuery.isNotEmpty,
              ),
            ),
          ),

          // ── Category Filter ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CategoryFilterBar(
                selectedCategory: provider.selectedCategory,
                onCategorySelected: provider.setCategory,
              ),
            ),
          ),

          // ── Section Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _filterLabel(provider.filter),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${expenses.length} expense${expenses.length == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expense List ──
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else if (expenses.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(onAddTap: onAddExpense),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final expense = expenses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ExpenseListTile(
                        expense: expense,
                        index: index,
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideX(
                      begin: 0.05,
                    );
                  },
                  childCount: expenses.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _filterLabel(ExpenseFilter filter) {
    switch (filter) {
      case ExpenseFilter.thisMonth:
        return 'This Month';
      case ExpenseFilter.lastMonth:
        return 'Last Month';
      case ExpenseFilter.thisWeek:
        return 'This Week';
      case ExpenseFilter.all:
        return 'All Expenses';
    }
  }
}

// ─── Profile Page ─────────────────────────────────────────────────────────────

class _ProfilePage extends StatelessWidget {
  final ExpenseProvider provider;
  const _ProfilePage({required this.provider});

  @override
  Widget build(BuildContext context) {
    final user = provider.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),

            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isAnonymous
                      ? '👤'
                      : (user?.email?.substring(0, 1).toUpperCase() ?? '?'),
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ).animate().scale(duration: 400.ms),

            const SizedBox(height: 16),

            Text(
              isAnonymous ? 'Guest User' : (user?.email ?? 'Unknown'),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            if (isAnonymous)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Sign in to sync across devices',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Info cards
            _ProfileTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: isAnonymous ? 'Guest (Anonymous)' : (user?.email ?? '—'),
            ),
            const SizedBox(height: 8),
            _ProfileTile(
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value:
                  user?.metadata.creationTime != null
                      ? DateFormat('MMMM d, yyyy').format(
                        user!.metadata.creationTime!,
                      )
                      : '—',
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await provider.signOut();
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                label: Text(
                  'Sign Out',
                  style: GoogleFonts.inter(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Filter & Sort',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'DATE RANGE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                ExpenseFilter.values.map((f) {
                  final isSelected = provider.filter == f;
                  return GestureDetector(
                    onTap: () {
                      provider.setFilter(f);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppTheme.primary.withValues(alpha: 0.15)
                                : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected ? AppTheme.primary : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        _filterLabel(f),
                        style: GoogleFonts.inter(
                          color:
                              isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'SORT BY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                SortOrder.values.map((s) {
                  final isSelected = provider.sortOrder == s;
                  return GestureDetector(
                    onTap: () {
                      provider.setSortOrder(s);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppTheme.accent.withValues(alpha: 0.15)
                                : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected ? AppTheme.accent : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        _sortLabel(s),
                        style: GoogleFonts.inter(
                          color:
                              isSelected
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
            ],
          ),
        ),
      ),
    ),
  );
}

  String _filterLabel(ExpenseFilter f) {
    switch (f) {
      case ExpenseFilter.all:
        return 'All Time';
      case ExpenseFilter.thisMonth:
        return 'This Month';
      case ExpenseFilter.lastMonth:
        return 'Last Month';
      case ExpenseFilter.thisWeek:
        return 'This Week';
    }
  }

  String _sortLabel(SortOrder s) {
    switch (s) {
      case SortOrder.dateDesc:
        return 'Newest First';
      case SortOrder.dateAsc:
        return 'Oldest First';
      case SortOrder.amountDesc:
        return 'Highest Amount';
      case SortOrder.amountAsc:
        return 'Lowest Amount';
    }
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
