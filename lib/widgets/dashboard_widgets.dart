import 'dart:math' show max;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../theme/tokens.dart';
import 'flowcash_widgets.dart';

// ---------------------------------------------------------------------------
// BalanceCard
// ---------------------------------------------------------------------------

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expenses;
  final String currencyCode;

  const BalanceCard({
    Key? key,
    required this.balance,
    required this.income,
    required this.expenses,
    this.currencyCode = 'USD',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FlowCashTokens.indigoDeep,
            FlowCashTokens.indigo,
            FlowCashTokens.teal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: FlowCashTokens.indigoDeep.withOpacity(0.45),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Shine effect
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.28),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label + badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFBFBFBF),
                        letterSpacing: 1.6,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withOpacity(0.18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: FlowCashTokens.lime,
                              boxShadow: [
                                BoxShadow(
                                  color: FlowCashTokens.lime.withOpacity(0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            currencyCode,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Balance amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      NumberFormat('#,##0').format(balance.toInt()),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1.8,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '.${((balance % 1) * 100).toStringAsFixed(0).padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Mini chips
                Row(
                  children: [
                    Expanded(child: _MiniChip(type: 'in', amount: income)),
                    const SizedBox(width: 10),
                    Expanded(child: _MiniChip(type: 'out', amount: expenses)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String type;
  final double amount;

  const _MiniChip({
    Key? key,
    required this.type,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIn = type == 'in';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isIn
                  ? FlowCashTokens.teal.withOpacity(0.28)
                  : FlowCashTokens.coral.withOpacity(0.28),
            ),
            child: Icon(
              isIn ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: isIn ? FlowCashTokens.lime : const Color(0xFFFFD5DC),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIn ? 'INGRESOS' : 'GASTOS',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.4,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\$${NumberFormat('#,##0.00').format(amount)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QuickActionGrid
// ---------------------------------------------------------------------------

class QuickActionGrid extends StatelessWidget {
  final VoidCallback onIncome;
  final VoidCallback onExpense;
  final VoidCallback onReports;

  const QuickActionGrid({
    Key? key,
    required this.onIncome,
    required this.onExpense,
    required this.onReports,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _QuickActionTile(
          icon: Icons.add,
          label: 'Ingreso',
          color: FlowCashTokens.teal,
          onPressed: onIncome,
        ),
        _QuickActionTile(
          icon: Icons.remove,
          label: 'Gasto',
          color: FlowCashTokens.coral,
          onPressed: onExpense,
        ),
        _QuickActionTile(
          icon: Icons.bar_chart,
          label: 'Reportes',
          color: FlowCashTokens.amber,
          onPressed: onReports,
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _QuickActionTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color, color.withOpacity(0.8)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.6),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onPressed,
                          borderRadius: BorderRadius.circular(12),
                          child: Icon(icon, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: FlowCashTokens.textDark,
            letterSpacing: -0.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TransactionListItem
// ---------------------------------------------------------------------------

class TransactionListItem extends StatelessWidget {
  final Expense expense;
  final bool isLast;
  final VoidCallback? onDelete;

  const TransactionListItem({
    Key? key,
    required this.expense,
    required this.isLast,
    this.onDelete,
  }) : super(key: key);

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('drink')) {
      return FlowCashTokens.categoryColors['food']!;
    }
    if (cat.contains('transport') ||
        cat.contains('car') ||
        cat.contains('uber')) {
      return FlowCashTokens.categoryColors['transport']!;
    }
    if (cat.contains('salary') || cat.contains('income')) {
      return FlowCashTokens.categoryColors['salary']!;
    }
    if (cat.contains('entertainment') || cat.contains('netflix')) {
      return FlowCashTokens.categoryColors['entertainment']!;
    }
    if (cat.contains('shopping') || cat.contains('cart')) {
      return FlowCashTokens.categoryColors['shopping']!;
    }
    if (cat.contains('health') || cat.contains('medical')) {
      return FlowCashTokens.categoryColors['health']!;
    }
    if (cat.contains('gift')) {
      return FlowCashTokens.categoryColors['gift']!;
    }
    return FlowCashTokens.categoryColors['bills']!;
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food')) return Icons.restaurant;
    if (cat.contains('transport')) return Icons.directions_car;
    if (cat.contains('income') || cat.contains('salary')) {
      return Icons.account_balance_wallet;
    }
    if (cat.contains('entertainment')) return Icons.movie;
    if (cat.contains('shopping')) return Icons.shopping_cart;
    if (cat.contains('health')) return Icons.favorite;
    if (cat.contains('gift')) return Icons.card_giftcard;
    return Icons.receipt_long;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = expense.type == ExpenseType.income;
    final amountColor = isIncome ? FlowCashTokens.teal : FlowCashTokens.coral;
    final categoryLabel = expense.category ?? 'Sin categoría';
    final categoryColor = _getCategoryColor(categoryLabel);
    final categoryIcon = _getCategoryIcon(categoryLabel);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor,
                      categoryColor.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 1,
                      left: 1,
                      right: 1,
                      height: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Icon(categoryIcon, color: Colors.white, size: 20),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FlowCashTokens.textDark,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Text(
                          isIncome ? 'Ingreso' : 'Gasto',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: FlowCashTokens.textDarkMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 2,
                          height: 2,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: FlowCashTokens.textDarkDim,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('d MMM').format(expense.transactionDate),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: FlowCashTokens.textDarkMuted,
                          ),
                        ),
                      ],
                    ),
                    if (expense.isUpcoming) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: FlowCashTokens.amber.withOpacity(0.12),
                              border: Border.all(
                                color: FlowCashTokens.amber.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.schedule,
                                    size: 10, color: FlowCashTokens.amber),
                                SizedBox(width: 4),
                                Text(
                                  'Próximo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: FlowCashTokens.amber,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '−'}\$${expense.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: FlowCashTokens.textDarkDim,
                    hoverColor: FlowCashTokens.coral.withOpacity(0.12),
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: onDelete,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(
              height: 1,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// WebStatsCard — income/expenses summary + sparkline
// ---------------------------------------------------------------------------

class WebStatsCard extends StatelessWidget {
  final double income;
  final double expenses;

  const WebStatsCard({
    Key? key,
    required this.income,
    required this.expenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final hasData = income > 0 || expenses > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: FlowCashTokens.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Este mes',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: FlowCashTokens.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          if (!hasData)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Sin movimientos este mes',
                  style: TextStyle(
                    fontSize: 13,
                    color: FlowCashTokens.textDarkMuted,
                  ),
                ),
              ),
            )
          else ...[
            _FlowChip(
              label: 'Ingresos',
              amount: '\$${fmt.format(income)}',
              isPositive: true,
            ),
            const SizedBox(height: 10),
            _FlowChip(
              label: 'Gastos',
              amount: '\$${fmt.format(expenses)}',
              isPositive: false,
            ),
            const SizedBox(height: 12),
            const Text(
              '14 días recientes',
              style: TextStyle(
                fontSize: 11,
                color: FlowCashTokens.textDarkMuted,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: CustomPaint(
                painter: _SparklinePainter(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FlowChip extends StatelessWidget {
  final String label;
  final String amount;
  final bool isPositive;

  const _FlowChip({
    required this.label,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? FlowCashTokens.teal : FlowCashTokens.coral;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.15),
          ),
          child: Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: FlowCashTokens.textDarkMuted,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  static const _points = [
    40.0, 32, 36, 22, 26, 18, 24, 14, 20, 10, 16, 22, 12, 8
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (_points.isEmpty) return;

    final minY = _points.reduce((a, b) => a < b ? a : b);
    final maxY = _points.reduce((a, b) => a > b ? a : b);
    final range = max(maxY - minY, 1.0);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < _points.length; i++) {
      final x = i / (_points.length - 1) * size.width;
      final y = size.height - ((_points[i] - minY) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close fill path to bottom
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          FlowCashTokens.indigo.withOpacity(0.35),
          FlowCashTokens.teal.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke gradient
    final strokePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [FlowCashTokens.indigo, FlowCashTokens.teal],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// WebCategoryCard — category breakdown with progress bars
// ---------------------------------------------------------------------------

class WebCategoryCard extends StatelessWidget {
  final List<Expense> expenses;

  const WebCategoryCard({
    Key? key,
    required this.expenses,
  }) : super(key: key);

  List<_CategoryRow> _computeCategories() {
    final totals = <String, double>{};
    double grandTotal = 0;
    for (final e in expenses) {
      if (e.type == ExpenseType.expense) {
        final key = e.category ?? 'Sin categoría';
        totals[key] = (totals[key] ?? 0) + e.amount;
        grandTotal += e.amount;
      }
    }
    if (grandTotal == 0) return const [];

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((entry) {
      final cat = entry.key.toLowerCase();
      Color color = FlowCashTokens.categoryColors['bills']!;
      if (cat.contains('food') || cat.contains('comida')) {
        color = FlowCashTokens.categoryColors['food']!;
      }
      if (cat.contains('transport')) {
        color = FlowCashTokens.categoryColors['transport']!;
      }
      if (cat.contains('entertainment') || cat.contains('entretenimiento')) {
        color = FlowCashTokens.categoryColors['entertainment']!;
      }
      if (cat.contains('shopping') || cat.contains('compras')) {
        color = FlowCashTokens.categoryColors['shopping']!;
      }
      if (cat.contains('health') || cat.contains('salud')) {
        color = FlowCashTokens.categoryColors['health']!;
      }
      if (cat.contains('gift') || cat.contains('regalo')) {
        color = FlowCashTokens.categoryColors['gift']!;
      }
      if (cat.contains('salary') ||
          cat.contains('salario') ||
          cat.contains('income')) {
        color = FlowCashTokens.categoryColors['salary']!;
      }
      return _CategoryRow(entry.key, entry.value / grandTotal, color);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _computeCategories();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: FlowCashTokens.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top categorías',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: FlowCashTokens.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Sin datos de categorías',
                  style: TextStyle(
                    fontSize: 13,
                    color: FlowCashTokens.textDarkMuted,
                  ),
                ),
              ),
            )
          else
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _CategoryProgressRow(row: row),
                )),
        ],
      ),
    );
  }
}

class _CategoryRow {
  final String name;
  final double fraction;
  final Color color;
  const _CategoryRow(this.name, this.fraction, this.color);
}

class _CategoryProgressRow extends StatelessWidget {
  final _CategoryRow row;
  const _CategoryProgressRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final pct = (row.fraction * 100).toStringAsFixed(0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              row.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: FlowCashTokens.textDarkMuted,
              ),
            ),
            Text(
              '$pct%',
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FlowCashTokens.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            FractionallySizedBox(
              widthFactor: row.fraction.clamp(0.0, 1.0),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: [row.color, row.color.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// FilterPillRow — filter pills for transaction list
// ---------------------------------------------------------------------------

class FilterPillRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const FilterPillRow({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const options = ['Todos', 'Ingresos', 'Gastos', 'Este mes', 'Próximos'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.map((option) {
        final isActive = option == selected;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: isActive
                      ? FlowCashTokens.teal.withOpacity(0.12)
                      : Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: isActive
                        ? FlowCashTokens.teal.withOpacity(0.3)
                        : FlowCashTokens.borderDark,
                  ),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? FlowCashTokens.teal
                          : FlowCashTokens.textDarkMuted,
                    ),
                    child: Text(option),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// WebTopNav — top navigation bar for web dashboard layout
// ---------------------------------------------------------------------------

class WebTopNav extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;

  const WebTopNav({
    Key? key,
    required this.userName,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: FlowCashTokens.bgDark.withOpacity(0.6),
            border: Border(
              bottom: BorderSide(
                color: FlowCashTokens.borderDark,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              children: [
                // Left: Logo
                SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      FlowCashLogoMark(size: 36, showShine: true),
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            FlowCashTokens.indigo,
                            FlowCashTokens.teal,
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'FlowCash',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Right: Search + bell + avatar
                SizedBox(
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Search bar
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(color: FlowCashTokens.borderDark),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: FlowCashTokens.teal,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Search ⌘K',
                              style: TextStyle(
                                fontSize: 13,
                                color: FlowCashTokens.textDarkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Avatar + popup logout
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'logout') onLogout();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'logout',
                            child: Text('Cerrar sesión'),
                          ),
                        ],
                        child: Row(
                          children: [
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
                              ),
                              child: Center(
                                child: Text(
                                  userName.substring(0, 2).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

