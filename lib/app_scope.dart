import 'package:flutter/widgets.dart';

import 'controllers/credit_controller.dart';
import 'controllers/expense_controller.dart';
import 'controllers/profile_controller.dart';

/// Makes the controllers available to every screen:
/// `AppScope.of(context).expenses`.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.expenses,
    required this.credits,
    required this.profile,
    required super.child,
  });

  final ExpenseController expenses;
  final CreditController credits;
  final ProfileController profile;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      expenses != oldWidget.expenses ||
      credits != oldWidget.credits ||
      profile != oldWidget.profile;
}
