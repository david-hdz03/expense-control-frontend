enum ExpenseType {
  expense,
  income;

  static ExpenseType fromWire(String value) {
    final lower = value.toLowerCase();
    if (lower == 'ingreso' || lower == 'ingresos') return ExpenseType.income;
    return ExpenseType.expense;
  }

  int toTypeId() => this == ExpenseType.expense ? 1 : 2;
}

class Expense {
  final int id;
  final double amount;
  final ExpenseType type;
  final String? category;
  final int? categoryId;
  final DateTime transactionDate;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.type,
    this.category,
    this.categoryId,
    required this.transactionDate,
    required this.createdAt,
  });

  bool get isUpcoming => transactionDate.isAfter(DateTime.now());

  factory Expense.fromJson(Map<String, dynamic> json) {
    final typeObj = json['transaction_type'] as Map<String, dynamic>?;
    final categoryObj = json['category'] as Map<String, dynamic>?;
    return Expense(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      type: ExpenseType.fromWire(typeObj?['name'] as String? ?? 'gasto'),
      category: categoryObj?['name'] as String?,
      categoryId: categoryObj != null ? categoryObj['id'] as int? : null,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ExpenseDraft {
  final double amount;
  final ExpenseType type;
  final int? categoryId;
  final DateTime? transactionDate;

  const ExpenseDraft({
    required this.amount,
    required this.type,
    this.categoryId,
    this.transactionDate,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount.round(),
        'transaction_type_id': type.toTypeId(),
        if (categoryId != null) 'category_id': categoryId,
        if (transactionDate != null)
          'transaction_date': transactionDate!.toIso8601String(),
      };
}
