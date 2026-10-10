import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../core/utils/validators.dart';
import '../models/credit.dart';
import '../repositories/repository_exception.dart';
import '../widgets/app_header.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import '../widgets/form_fields.dart';
import '../widgets/primary_button.dart';

/// Credit form (type, payee, amount, due date, plan) and the saved list.
class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _creditType = CreditType.values.first;
  String _planType = PlanType.monthly;
  DateTime _dueDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final credit = Credit(
      creditType: _creditType,
      name: _nameController.text.trim(),
      amount: Validators.parseAmount(_amountController.text)!,
      dueDate: DateTime(_dueDate.year, _dueDate.month, _dueDate.day),
      planType: _planType,
    );

    setState(() => _isSaving = true);
    try {
      await AppScope.of(context).credits.addCredit(credit);
      if (!mounted) return;
      _formKey.currentState!.reset();
      _nameController.clear();
      _amountController.clear();
      showMessage(context, 'Added to your saved list');
    } on RepositoryException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete(Credit credit) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete credit?',
      message: '"${credit.name}" will be removed from your saved list.',
    );
    if (!confirmed || !mounted) return;
    try {
      await AppScope.of(context).credits.deleteCredit(credit);
    } on RepositoryException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).credits;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        const AppHeader(title: 'Credit'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 21, bottom: bottomPadding + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppSelectField(
                          label: 'Credit Type',
                          value: _creditType,
                          options: CreditType.values,
                          horizontalPadding: 18.5,
                          chevronWidth: 23.14,
                          iconRightPadding: 17,
                          onChanged: (value) =>
                              setState(() => _creditType = value),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'To',
                          controller: _nameController,
                          labelGap: 8,
                          horizontalPadding: 18,
                          hintText: 'e.g. Netflix',
                          textCapitalization: TextCapitalization.words,
                          validator: (value) =>
                              Validators.requiredText(value, field: 'Name'),
                        ),
                        const SizedBox(height: 14),
                        AmountField(
                          controller: _amountController,
                          validator: Validators.amount,
                          labelGap: 8,
                          highlighted: false,
                        ),
                        const SizedBox(height: 14),
                        AppDateField(
                          label: 'Date',
                          date: _dueDate,
                          iconRightPadding: 17,
                          onChanged: (value) =>
                              setState(() => _dueDate = value),
                        ),
                        const SizedBox(height: 14),
                        AppSelectField(
                          label: 'Plan Type',
                          value: _planType,
                          options: PlanType.values,
                          horizontalPadding: 18.5,
                          chevronWidth: 23.14,
                          iconRightPadding: 17,
                          onChanged: (value) =>
                              setState(() => _planType = value),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Save',
                          isLoading: _isSaving,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 29),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    'Your Saved Lists',
                    style: AppTextStyles.savedListTitle,
                  ),
                ),
                const SizedBox(height: 20),
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    if (controller.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Text(
                          controller.errorMessage!,
                          style: AppTextStyles.error,
                        ),
                      );
                    }
                    final credits = controller.credits;
                    if (credits.isEmpty) {
                      return const Center(
                        child: EmptyState(
                          title: 'Nothing saved yet',
                          message:
                              'Saved subscriptions, loans and bills '
                              'will appear here.',
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < credits.length; i++) ...[
                          if (i > 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                              child: Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: AppColors.divider,
                              ),
                            ),
                          _CreditRow(
                            credit: credits[i],
                            onLongPress: () => _delete(credits[i]),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.credit, required this.onLongPress});

  final Credit credit;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDue = Formatters.isDueTodayOrOverdue(credit.dueDate);
    final isToday = Formatters.relativeDate(credit.dueDate) == 'Today';

    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: SizedBox(
          height: 41,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      credit.name,
                      style: AppTextStyles.rowTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        style: AppTextStyles.rowSubtitle,
                        children: [
                          const TextSpan(text: 'Due '),
                          TextSpan(
                            text: isToday
                                ? 'Today'
                                : 'On ${Formatters.dueDate(credit.dueDate)}',
                            style: isDue
                                ? const TextStyle(color: AppColors.overdue)
                                : null,
                          ),
                        ],
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 1),
                  Text(credit.planType, style: AppTextStyles.rowSubtitle),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.currency(credit.amount),
                    style: AppTextStyles.rowAmount.copyWith(
                      color: AppColors.textAmount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
