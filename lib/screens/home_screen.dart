import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_scope.dart';
import '../core/constants/app_assets.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../models/expense_summary.dart';
import '../widgets/blurred_shadow.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  /// Number of recent transactions shown on Home (as in the Figma frame).
  static const int recentCount = 3;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final padding = MediaQuery.paddingOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ListenableBuilder(
        listenable: Listenable.merge([scope.expenses, scope.profile]),
        builder: (context, _) {
          final controller = scope.expenses;
          final recent = controller.expenses.take(recentCount).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              top: padding.top + 22,
              bottom: padding.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Formatters.greeting(),
                        style: AppTextStyles.greeting,
                      ),
                      const SizedBox(height: 2),
                      Text(scope.profile.name, style: AppTextStyles.userName),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _BalanceCard(summary: controller.summary),
                ),
                const SizedBox(height: 33),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          label: 'Daily Average',
                          amount: controller.summary.dailyAverage,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatBox(
                          label: 'Weekly',
                          amount: controller.summary.weekly,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transactions History',
                        style: AppTextStyles.sectionTitle,
                      ),
                      GestureDetector(
                        onTap: onSeeAll,
                        child: const Text(
                          'See all',
                          style: AppTextStyles.seeAll,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 19),
                if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Text(
                      controller.errorMessage!,
                      style: AppTextStyles.error,
                    ),
                  )
                else if (controller.isLoading && recent.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (recent.isEmpty)
                  const Center(
                    child: EmptyState(
                      title: 'No transactions yet',
                      message: 'Tap the + button to add your first expense.',
                    ),
                  )
                else
                  for (var i = 0; i < recent.length; i++) ...[
                    if (i > 0) const SizedBox(height: 25),
                    TransactionRow(expense: recent[i]),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Teal "Total Balance" card with the blurred shadow underneath.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary});

  final ExpenseSummary summary;

  String _balanceText(double balance) {
    if (balance < 0) return '- ${Formatters.currency(-balance)}';
    return Formatters.currency(balance);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 201,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Figma: rgba(27,92,88,0.9) rectangle, 9 px blur, 80 % opacity.
          Positioned(
            left: 9,
            right: 9,
            top: 118.58,
            height: 83.415,
            child: Opacity(
              opacity: 0.8,
              child: BlurredShadow(
                color: AppColors.balanceCardShadow,
                sigma: 9,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Balance', style: AppTextStyles.cardLabel),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _balanceText(summary.balance),
                    style: AppTextStyles.totalBalance,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const _ArrowCircle(pointsUp: false),
                    const SizedBox(width: 7),
                    const Text('Income', style: AppTextStyles.incomeLabel),
                    const Spacer(),
                    const _ArrowCircle(pointsUp: true),
                    const SizedBox(width: 6),
                    const Text('Expenses', style: AppTextStyles.expensesLabel),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Formatters.currency(summary.totalIncome),
                          style: AppTextStyles.cardAmount,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          Formatters.currency(summary.totalExpense),
                          style: AppTextStyles.cardAmount,
                        ),
                      ),
                    ),
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

class _ArrowCircle extends StatelessWidget {
  const _ArrowCircle({required this.pointsUp});

  final bool pointsUp;

  @override
  Widget build(BuildContext context) {
    final arrow = SvgPicture.asset(AppAssets.arrowDown, width: 18, height: 18);
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.frostedCircle,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: pointsUp ? Transform.flip(flipY: true, child: arrow) : arrow,
    );
  }
}

/// "DAILY AVERAGE" / "WEEKLY" box.
class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: 12),
        Container(
          height: 69,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1.308),
            borderRadius: BorderRadius.circular(10.462),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              Formatters.currency(amount),
              style: AppTextStyles.statValue,
            ),
          ),
        ),
      ],
    );
  }
}
