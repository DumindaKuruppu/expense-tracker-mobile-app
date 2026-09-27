import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_card.dart';
import 'add_edit_expense_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMonthPicker(BuildContext context, ExpenseProvider provider) async {
    final DateTime current = provider.selectedMonth;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'SELECT MONTH & YEAR',
    );
    if (picked != null) {
      provider.setSelectedMonth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search expenses by title or note...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                onChanged: (value) {
                  provider.setSearchQuery(value);
                },
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  provider.setSearchQuery('');
                } else {
                  _isSearching = true;
                }
              });
            },
            tooltip: _isSearching ? 'Close Search' : 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart_outline, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
            tooltip: 'Spending Analytics',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Monthly Summary Card Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: SummaryCard(
                totalAmount: provider.monthlyTotal,
                selectedMonth: provider.selectedMonth,
                transactionCount: provider.selectedMonthTransactionCount,
                percentageChange: provider.monthOverMonthPercentage,
                onPreviousMonth: () => provider.previousMonth(),
                onNextMonth: () => provider.nextMonth(),
                onSelectMonth: () => _showMonthPicker(context, provider),
              ),
            ),
          ),

          // Category Filters Horizontal Bar
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (provider.selectedCategory != null ||
                          provider.searchQuery.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            provider.resetFilters();
                            setState(() {
                              _isSearching = false;
                            });
                          },
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text(
                            'Clear Filters',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.expense,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      CategoryChip(
                        label: 'All',
                        icon: Icons.grid_view_rounded,
                        color: AppColors.primary,
                        isSelected: provider.selectedCategory == null,
                        onTap: () => provider.setSelectedCategory(null),
                      ),
                      const SizedBox(width: 8),
                      ...AppConstants.categories.map((cat) {
                        final isSelected =
                            provider.selectedCategory?.toLowerCase() ==
                                cat.name.toLowerCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CategoryChip(
                            label: cat.name,
                            icon: cat.icon,
                            color: cat.color,
                            isSelected: isSelected,
                            onTap: () => provider.setSelectedCategory(cat.name),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Header for Expenses List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${provider.filteredExpenses.length} items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main List / States Handling
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (provider.errorMessage != null)
            SliverFillRemaining(
              child: ErrorView(
                message: provider.errorMessage!,
                onRetry: () => provider.resetFilters(),
              ),
            )
          else if (provider.filteredExpenses.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                title: provider.searchQuery.isNotEmpty || provider.selectedCategory != null
                    ? 'No Matching Expenses'
                    : 'No Expenses Recorded',
                message: provider.searchQuery.isNotEmpty || provider.selectedCategory != null
                    ? 'Try adjusting your search query or category filter.'
                    : 'No expense records found for this month.',
                buttonText: provider.searchQuery.isNotEmpty || provider.selectedCategory != null
                    ? 'Clear Filters'
                    : 'Add First Expense',
                onButtonPressed: () {
                  if (provider.searchQuery.isNotEmpty || provider.selectedCategory != null) {
                    _searchController.clear();
                    provider.resetFilters();
                    setState(() {
                      _isSearching = false;
                    });
                  } else {
                    _navigateToAddEdit(context);
                  }
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final expense = provider.filteredExpenses[index];
                    return Dismissible(
                      key: Key('expense-${expense.id}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await ConfirmDeleteDialog.show(
                          context,
                          title: 'Delete Expense',
                          content:
                              'Are you sure you want to delete "${expense.title}"? This cannot be undone.',
                        );
                      },
                      onDismissed: (direction) {
                        provider.deleteExpense(expense.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleted "${expense.title}"'),
                            action: SnackBarAction(
                              label: 'Dismiss',
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.expense,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.delete_forever,
                                color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: ExpenseCard(
                        expense: expense,
                        onTap: () => _navigateToAddEdit(context, expense: expense),
                      ),
                    );
                  },
                  childCount: provider.filteredExpenses.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  void _navigateToAddEdit(BuildContext context, {ExpenseModel? expense}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditExpenseScreen(expense: expense),
      ),
    );
  }
}
