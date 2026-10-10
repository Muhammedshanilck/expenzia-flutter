import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/theme/app_text_styles.dart';
import '../models/expense.dart';
import '../repositories/repository_exception.dart';
import '../widgets/app_header.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import '../widgets/swipeable_transaction_row.dart';
import 'transaction_form_screen.dart';

/// "Transaction History": every saved transaction, newest first.
/// Swipe a row left (or tap it) to edit or delete.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _edit(BuildContext context, Expense expense) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(expense: expense),
      ),
    );
    if (saved == true && context.mounted) {
      showMessage(context, 'Transaction updated');
    }
  }

  Future<void> _delete(BuildContext context, Expense expense) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete transaction?',
      message: '"${expense.title}" will be permanently deleted.',
    );
    if (!confirmed || !context.mounted) return;

    try {
      await AppScope.of(context).expenses.deleteExpense(expense);
      if (context.mounted) showMessage(context, 'Transaction deleted');
    } on RepositoryException catch (e) {
      if (context.mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).expenses;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        const AppHeader(title: 'Transaction History'),
        Expanded(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final expenses = controller.expenses;

              if (controller.errorMessage != null) {
                return Center(
                  child: Text(
                    controller.errorMessage!,
                    style: AppTextStyles.error,
                  ),
                );
              }
              if (controller.isLoading && expenses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (expenses.isEmpty) {
                return const Center(
                  child: EmptyState(
                    title: 'No transactions yet',
                    message: 'Tap the + button to add your first expense.',
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.only(top: 32, bottom: bottomPadding + 16),
                itemCount: expenses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return SwipeableTransactionRow(
                    key: ValueKey(expense.id),
                    expense: expense,
                    onEdit: () => _edit(context, expense),
                    onDelete: () => _delete(context, expense),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
