import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../providers/expenses_provider.dart';
import '../theme/tokens.dart';
import '../widgets/dashboard_widgets.dart';
import 'expense_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedFilter = 'Todos';
  String _searchQuery = '';

  Future<void> _deleteExpense(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF232340),
        title: const Text(
          'Eliminar movimiento',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: const Text(
          '¿Seguro que quieres eliminar este movimiento?',
          style: TextStyle(color: Color(0xFF9090A8), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF9090A8))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar',
                style: TextStyle(color: Color(0xFFFF6B8A))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(apiServiceProvider).deleteExpense(id);
      ref.invalidate(expensesProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  Future<void> _openExpenseForm({ExpenseType type = ExpenseType.expense}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ExpenseFormScreen(initialType: type)),
    );
    if (saved == true) {
      ref.invalidate(expensesProvider);
    }
  }

  bool _reportsUnlocked(List<Expense> expenses) {
    if (expenses.isEmpty) return false;
    final earliest = expenses
        .map((e) => e.transactionDate)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime.now().difference(earliest).inDays >= 30;
  }

  List<Expense> _applyFilter(List<Expense> expenses) {
    final now = DateTime.now();
    var result = switch (_selectedFilter) {
      'Ingresos' => expenses.where((e) => e.type == ExpenseType.income).toList(),
      'Gastos'   => expenses.where((e) => e.type == ExpenseType.expense).toList(),
      'Este mes' => expenses.where((e) =>
          e.transactionDate.year == now.year &&
          e.transactionDate.month == now.month).toList(),
      'Próximos' => expenses.where((e) => e.isUpcoming).toList(),
      _          => expenses,
    };
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return result;
    return result.where((e) {
      final categoryMatch = (e.category ?? '').toLowerCase().contains(q);
      final typeLabel = e.type == ExpenseType.income ? 'ingreso' : 'gasto';
      final typeMatch = typeLabel.contains(q);
      return categoryMatch || typeMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final authState = ref.watch(authProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.name
        : 'Alex';
    final currencyCode = authState is AuthAuthenticated
        ? authState.user.currencyCode
        : 'USD';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 900;
        if (isWeb) {
          return _buildWebLayout(
              context, expensesAsync, userName, currencyCode);
        }
        return _buildMobileLayout(
            context, expensesAsync, userName, currencyCode);
      },
    );
  }

  // -------------------------------------------------------------------------
  // Mobile layout (original, unchanged)
  // -------------------------------------------------------------------------
  Widget _buildMobileLayout(
    BuildContext context,
    AsyncValue<List<Expense>> expensesAsync,
    String userName,
    String currencyCode,
  ) {
    return Scaffold(
      backgroundColor: FlowCashTokens.bgDark,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 120,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with avatar and notification
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                FlowCashTokens.indigo,
                                FlowCashTokens.teal,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: FlowCashTokens.indigo.withOpacity(0.5),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: -6,
                                left: -6,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.45),
                                        Colors.white.withOpacity(0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                userName.substring(0, 2).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Buenos días',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: FlowCashTokens.textDarkMuted,
                                ),
                              ),
                              Text(
                                'Hola, ${userName.split('.').first} \u{1F44B}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: FlowCashTokens.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Balance card
                    expensesAsync.when(
                      loading: () => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('Error al cargar el balance'),
                        ),
                      ),
                      data: (expenses) {
                        final balance = expenses.fold<double>(0, (sum, e) {
                          return sum +
                              (e.type == ExpenseType.income
                                  ? e.amount
                                  : -e.amount);
                        });
                        final income = expenses
                            .where((e) => e.type == ExpenseType.income)
                            .fold<double>(0, (sum, e) => sum + e.amount);
                        final totalExpenses = expenses
                            .where((e) => e.type == ExpenseType.expense)
                            .fold<double>(0, (sum, e) => sum + e.amount);
                        return BalanceCard(
                          balance: balance,
                          income: income,
                          expenses: totalExpenses,
                          currencyCode: currencyCode,
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    // Quick actions
                    QuickActionGrid(
                      onIncome: () => _openExpenseForm(type: ExpenseType.income),
                      onExpense: () => _openExpenseForm(),
                      onReports: () {},
                      reportsUnlocked: _reportsUnlocked(expensesAsync.value ?? []),
                    ),
                    const SizedBox(height: 22),
                    // Recent transactions header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Movimientos recientes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: FlowCashTokens.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text(
                            'Ver todo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: FlowCashTokens.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Transactions list
                    expensesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, _) =>
                          Center(child: Text('Error: $error')),
                      data: (expenses) {
                        final filtered = _applyFilter(expenses);
                        if (filtered.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 36,
                                      color: FlowCashTokens.textDarkDim),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Aún no hay movimientos',
                                    style: TextStyle(
                                      color: FlowCashTokens.textDarkMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Toca + para agregar tu primer movimiento',
                                    style: TextStyle(
                                      color: FlowCashTokens.textDarkDim,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Colors.white.withOpacity(0.04),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            children: List.generate(
                              filtered.length,
                              (i) => TransactionListItem(
                                expense: filtered[i],
                                isLast: i == filtered.length - 1,
                                onDelete: () => _deleteExpense(filtered[i].id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Web layout — top nav + 3-column body
  // -------------------------------------------------------------------------
  Widget _buildWebLayout(
    BuildContext context,
    AsyncValue<List<Expense>> expensesAsync,
    String userName,
    String currencyCode,
  ) {
    return Scaffold(
      backgroundColor: FlowCashTokens.bgDark,
      body: Stack(
        children: [
          // Ambient blobs (softer, larger for dashboard)
          Positioned(
            top: -200,
            left: -120,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    FlowCashTokens.indigo.withOpacity(0.28),
                    FlowCashTokens.indigo.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -180,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    FlowCashTokens.teal.withOpacity(0.2),
                    FlowCashTokens.teal.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              // Top nav
              WebTopNav(
                userName: userName,
                onLogout: () => ref.read(authProvider.notifier).logout(),
                onSearch: (q) => setState(() => _searchQuery = q),
              ),
              // 3-column body
              Expanded(
                child: _buildWebBody(
                    context, expensesAsync, userName, currencyCode),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebBody(
    BuildContext context,
    AsyncValue<List<Expense>> expensesAsync,
    String userName,
    String currencyCode,
  ) {
    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (expenses) {
        final balance = expenses.fold<double>(0, (sum, e) {
          return sum +
              (e.type == ExpenseType.income ? e.amount : -e.amount);
        });
        final income = expenses
            .where((e) => e.type == ExpenseType.income)
            .fold<double>(0, (sum, e) => sum + e.amount);
        final totalExpenses = expenses
            .where((e) => e.type == ExpenseType.expense)
            .fold<double>(0, (sum, e) => sum + e.amount);
        final filtered = _applyFilter(expenses);

        return Padding(
          padding: const EdgeInsets.fromLTRB(48, 24, 48, 48),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Left column (280px) ----
              SizedBox(
                width: 280,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buenos días, $userName \u{1F44B}',
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: FlowCashTokens.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Aquí está tu flujo hoy.',
                      style: TextStyle(
                        fontSize: 13,
                        color: FlowCashTokens.textDarkMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BalanceCard(
                      balance: balance,
                      income: income,
                      expenses: totalExpenses,
                      currencyCode: currencyCode,
                    ),
                    const SizedBox(height: 20),
                    // Quick actions container
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.white.withOpacity(0.04),
                        border: Border.all(
                          color: FlowCashTokens.borderDark,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACCIONES RÁPIDAS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: FlowCashTokens.textDarkMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          QuickActionGrid(
                            onIncome: () => _openExpenseForm(type: ExpenseType.income),
                            onExpense: () => _openExpenseForm(),
                            onReports: () {},
                            reportsUnlocked: _reportsUnlocked(expenses),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // ---- Center column (flex: 1) ----
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Movimientos recientes',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: FlowCashTokens.textDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const Spacer(),
                        FilterPillRow(
                          selected: _selectedFilter,
                          onChanged: (v) =>
                              setState(() => _selectedFilter = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(color: FlowCashTokens.borderDark),
                        ),
                        child: filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.receipt_long_outlined,
                                        size: 36,
                                        color: FlowCashTokens.textDarkDim),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Aún no hay movimientos',
                                      style: TextStyle(
                                        color: FlowCashTokens.textDarkMuted,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Toca + para agregar tu primer movimiento',
                                      style: TextStyle(
                                        color: FlowCashTokens.textDarkDim,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(6),
                                  itemCount: filtered.length,
                                  itemBuilder: (_, i) => TransactionListItem(
                                    expense: filtered[i],
                                    isLast: i == filtered.length - 1,
                                    onDelete: () => _deleteExpense(filtered[i].id),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // ---- Right column (280px) ----
              SizedBox(
                width: 280,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Este mes',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: FlowCashTokens.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    WebStatsCard(income: income, expenses: totalExpenses),
                    const SizedBox(height: 20),
                    Expanded(
                      child: WebCategoryCard(expenses: expenses),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

