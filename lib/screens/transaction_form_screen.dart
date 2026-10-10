import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/validators.dart';
import '../models/expense.dart';
import '../repositories/repository_exception.dart';
import '../widgets/app_header.dart';
import '../widgets/blurred_shadow.dart';
import '../widgets/dialogs.dart';
import '../widgets/form_fields.dart';
import '../widgets/primary_button.dart';

/// Add ("Transaction") and edit ("Edit Transaction") form.
/// Pops with `true` after the transaction is saved.
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.expense});

  /// The transaction to edit, or null to add a new one.
  final Expense? expense;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late String _category;
  late DateTime _date;
  bool _isSaving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _nameController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense == null ? '' : Formatters.amountInput(expense.amount),
    );
    _descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    _category = expense?.category ?? ExpenseCategory.expense;
    _date = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();
    final expense = Expense(
      id: widget.expense?.id,
      title: _nameController.text.trim(),
      amount: Validators.parseAmount(_amountController.text)!,
      category: _category,
      date: DateTime(_date.year, _date.month, _date.day),
      description: description.isEmpty ? null : description,
    );

    setState(() => _isSaving = true);
    final controller = AppScope.of(context).expenses;
    try {
      if (_isEditing) {
        await controller.updateExpense(expense);
      } else {
        await controller.addExpense(expense);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on RepositoryException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          AppHeader(
            title: _isEditing ? 'Edit Transaction' : 'Transaction',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
              child: Form(
                key: _formKey,
                child: Stack(
                  children: [
                    // Figma: box-shadow 0 0 35px rgba(0, 0, 0, 0.08).
                    Positioned.fill(
                      child: BlurredShadow(
                        color: AppColors.cardShadow,
                        sigma: 17.5,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    _buildCard(),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 73),
            child: PrimaryButton(
              label: 'Save',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 31, 20, 31),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSelectField(
            label: 'Transaction Type',
            value: _category,
            options: ExpenseCategory.values,
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Name',
            controller: _nameController,
            horizontalPadding: 17,
            hintText: 'e.g. Netflix',
            validator: (value) => Validators.requiredText(value, field: 'Name'),
          ),
          const SizedBox(height: 24),
          AmountField(
            controller: _amountController,
            validator: Validators.amount,
          ),
          const SizedBox(height: 24),
          AppDateField(
            date: _date,
            onChanged: (value) => setState(() => _date = value),
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: 'Description (optional)',
            controller: _descriptionController,
            hintText: 'Add a note',
            validator: Validators.description,
          ),
        ],
      ),
    );
  }
}
