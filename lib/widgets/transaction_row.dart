import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../models/expense.dart';

/// One row of the transaction lists: title + date on the left,
/// green (income) or red (expense) amount on the right.
/// Rows are 41 px tall; the amount sits 14 px below the row top.
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.expense,
    this.rightPadding = 22,
  });

  final Expense expense;
  final double rightPadding;

  static const double height = 41;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.only(left: 22, right: rightPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: AppTextStyles.rowTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.relativeDate(expense.date),
                    style: AppTextStyles.rowSubtitle,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                Formatters.signedCurrency(
                  expense.amount,
                  isIncome: expense.isIncome,
                ),
                style: AppTextStyles.rowAmount.copyWith(
                  color: expense.isIncome
                      ? AppColors.income
                      : AppColors.expense,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
