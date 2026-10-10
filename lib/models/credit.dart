class CreditType {
  CreditType._();

  static const List<String> values = [
    'Subscriptions',
    'Personal Loan',
    'Bills',
    'Insurance',
  ];
}

class PlanType {
  PlanType._();

  static const String monthly = 'Monthly';
  static const String oneTime = 'One-Time';
  static const String yearly = 'Yearly';

  static const List<String> values = [monthly, oneTime, yearly];
}

/// A saved credit / upcoming payment shown on the Credit screen.
class Credit {
  final int? id;
  final String creditType;
  final String name;
  final double amount;
  final DateTime dueDate;
  final String planType;

  const Credit({
    this.id,
    required this.creditType,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.planType,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'credit_type': creditType,
      'name': name,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'plan_type': planType,
    };
  }

  factory Credit.fromMap(Map<String, Object?> map) {
    return Credit(
      id: map['id'] as int?,
      creditType: map['credit_type'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date'] as String),
      planType: map['plan_type'] as String,
    );
  }
}
