/// The two categories offered by the "Transaction Type" dropdown in the design.
class ExpenseCategory {
  ExpenseCategory._();

  static const String expense = 'Expense';
  static const String income = 'Income';

  static const List<String> values = [expense, income];
}

/// A single transaction stored in the `expenses` table.
class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
  });

  bool get isIncome => category == ExpenseCategory.income;

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
    );
  }
}
