import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../providers/expenses_provider.dart';
import '../theme/tokens.dart';
import '../widgets/flowcash_widgets.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final ExpenseType initialType;

  const ExpenseFormScreen({super.key, this.initialType = ExpenseType.expense});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late ExpenseType _type;
  int? _selectedCategoryId;
  DateTime? _selectedDate;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final draft = ExpenseDraft(
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        type: _type,
        categoryId: _selectedCategoryId,
        transactionDate: _selectedDate,
      );
      await ref.read(apiServiceProvider).createExpense(draft);
      ref.invalidate(expensesProvider);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeId = _type == ExpenseType.expense ? 1 : 2;
    final categoriesAsync = ref.watch(categoriesProvider(typeId));

    return Scaffold(
      backgroundColor: FlowCashTokens.bgDark,
      appBar: AppBar(
        backgroundColor: FlowCashTokens.bgDark,
        title: const Text(
          'Nuevo movimiento',
          style: TextStyle(color: FlowCashTokens.textDark),
        ),
        iconTheme: const IconThemeData(color: FlowCashTokens.textDark),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Type selector
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(color: FlowCashTokens.borderDark),
                    ),
                    child: Row(
                      children: [
                        _TypeTab(
                          label: 'Gasto',
                          icon: Icons.remove_circle_outline,
                          color: FlowCashTokens.coral,
                          selected: _type == ExpenseType.expense,
                          onTap: () => setState(() {
                            _type = ExpenseType.expense;
                            _selectedCategoryId = null;
                          }),
                        ),
                        _TypeTab(
                          label: 'Ingreso',
                          icon: Icons.add_circle_outline,
                          color: FlowCashTokens.teal,
                          selected: _type == ExpenseType.income,
                          onTap: () => setState(() {
                            _type = ExpenseType.income;
                            _selectedCategoryId = null;
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Amount
                  FloatingInput(
                    label: 'Monto',
                    value: '',
                    icon: Icons.attach_money,
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requerido';
                      final parsed =
                          double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null) return 'Número inválido';
                      if (parsed <= 0) return 'Debe ser mayor a 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Category dropdown
                  categoriesAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (categories) => Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF1A1A2E),
                        border:
                            Border.all(color: FlowCashTokens.borderDark),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: _selectedCategoryId,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF232340),
                          hint: const Text(
                            'Categoría (opcional)',
                            style: TextStyle(
                              color: FlowCashTokens.textDarkMuted,
                              fontSize: 14,
                            ),
                          ),
                          style: const TextStyle(
                            color: FlowCashTokens.textDark,
                            fontSize: 15,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: FlowCashTokens.textDarkMuted,
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text(
                                'Sin categoría',
                                style: TextStyle(
                                    color: FlowCashTokens.textDarkMuted),
                              ),
                            ),
                            ...categories.map(
                              (cat) => DropdownMenuItem<int?>(
                                value: cat.id,
                                child: Text(cat.name),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedCategoryId = v),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date picker
                  GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? now,
                        firstDate: DateTime(now.year - 5),
                        lastDate: DateTime(now.year + 5),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: FlowCashTokens.teal,
                              onPrimary: Colors.black,
                              surface: Color(0xFF232340),
                              onSurface: FlowCashTokens.textDark,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF1A1A2E),
                        border: Border.all(
                          color: _selectedDate != null &&
                                  _selectedDate!.isAfter(DateTime.now())
                              ? FlowCashTokens.teal.withOpacity(0.5)
                              : FlowCashTokens.borderDark,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: _selectedDate != null
                                ? FlowCashTokens.teal
                                : FlowCashTokens.textDarkMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'Fecha (hoy por defecto)'
                                  : DateFormat('d MMM yyyy')
                                      .format(_selectedDate!),
                              style: TextStyle(
                                color: _selectedDate != null
                                    ? FlowCashTokens.textDark
                                    : FlowCashTokens.textDarkMuted,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (_selectedDate != null) ...[
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDate = null),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: FlowCashTokens.textDarkDim,
                              ),
                            ),
                            if (_selectedDate!.isAfter(DateTime.now())) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color:
                                      FlowCashTokens.teal.withOpacity(0.12),
                                  border: Border.all(
                                    color:
                                        FlowCashTokens.teal.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  'Próximo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: FlowCashTokens.teal,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FlowCashTokens.coral.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FlowCashTokens.coral.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: FlowCashTokens.coral,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  GradientButton(
                    text: 'Guardar',
                    onPressed: _submit,
                    isLoading: _submitting,
                    enabled: !_submitting,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? color.withOpacity(0.15)
                : Colors.transparent,
            border: selected
                ? Border.all(color: color.withOpacity(0.4))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected
                    ? color
                    : FlowCashTokens.textDarkMuted,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? color
                      : FlowCashTokens.textDarkMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
