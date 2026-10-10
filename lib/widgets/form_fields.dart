import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_assets.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';

/// Upper-case grey label shown above every field ("NAME", "AMOUNT", ...).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppTextStyles.label);
  }
}

/// The 50 px tall input box from Figma: 1 px #DDD border, radius 8.
/// When [highlighted] is true the border is always the 1.4 px green one
/// (the Figma amount field); otherwise it turns green when focused.
InputDecoration appInputDecoration({
  double horizontalPadding = 16,
  bool highlighted = false,
  String? prefixText,
  Widget? suffix,
  String? hintText,
}) {
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: width),
  );

  final normal = highlighted
      ? border(AppColors.green, 1.4)
      : border(AppColors.border, 1);

  return InputDecoration(
    isDense: true,
    hintText: hintText,
    hintStyle: AppTextStyles.fieldValue.copyWith(color: AppColors.textHint),
    contentPadding: EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: 16.5,
    ),
    prefixText: prefixText,
    prefixStyle: AppTextStyles.amountValue,
    suffixIcon: suffix,
    suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 20),
    enabledBorder: normal,
    focusedBorder: border(AppColors.green, 1.4),
    errorBorder: border(AppColors.overdue, 1),
    focusedErrorBorder: border(AppColors.overdue, 1.4),
    errorStyle: AppTextStyles.error,
    errorMaxLines: 2,
  );
}

/// Label + text box.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.horizontalPadding = 16,
    this.labelGap = 10,
    this.hintText,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final double horizontalPadding;
  final double labelGap;
  final String? hintText;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        SizedBox(height: labelGap),
        TextFormField(
          controller: controller,
          validator: validator,
          style: AppTextStyles.fieldValue,
          textCapitalization: textCapitalization,
          textInputAction: TextInputAction.next,
          cursorColor: AppColors.green,
          decoration: appInputDecoration(
            horizontalPadding: horizontalPadding,
            hintText: hintText,
          ),
        ),
      ],
    );
  }
}

/// Label + amount box with the "₹" prefix and the green "Clear" action.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    this.validator,
    this.label = 'Amount',
    this.labelGap = 10,
    this.highlighted = true,
  });

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final String label;
  final double labelGap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        SizedBox(height: labelGap),
        TextFormField(
          controller: controller,
          validator: validator,
          style: AppTextStyles.amountValue,
          cursorColor: AppColors.green,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: appInputDecoration(
            horizontalPadding: 20,
            highlighted: highlighted,
            prefixText: '₹ ',
            hintText: '0.00',
            suffix: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TextButton(
                onPressed: controller.clear,
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Clear', style: AppTextStyles.clearAction),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Label + dropdown box with the grey chevron from Figma.
class AppSelectField extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.horizontalPadding = 16,
    this.labelGap = 8,
    this.chevronWidth = 20,
    this.iconRightPadding = 15,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final double horizontalPadding;
  final double labelGap;
  final double chevronWidth;
  final double iconRightPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        SizedBox(height: labelGap),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          isDense: true,
          style: AppTextStyles.fieldValue,
          borderRadius: BorderRadius.circular(8),
          dropdownColor: AppColors.white,
          icon: Padding(
            padding: EdgeInsets.only(right: iconRightPadding),
            child: SvgPicture.asset(
              AppAssets.chevronDown,
              width: chevronWidth,
              height: 20,
            ),
          ),
          decoration: appInputDecoration(horizontalPadding: horizontalPadding)
              .copyWith(
                // The dense dropdown item is 24 px tall: 13 + 24 + 13 = 50 px.
                contentPadding: EdgeInsets.only(
                  left: horizontalPadding,
                  top: 13,
                  bottom: 13,
                ),
              ),
          items: [
            for (final option in options)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ],
    );
  }
}

/// Label + read-only box that opens the date picker, with the calendar icon.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.date,
    required this.onChanged,
    this.label = 'Date',
    this.labelGap = 10,
    this.iconRightPadding = 15,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  final String label;
  final double labelGap;
  final double iconRightPadding;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        SizedBox(height: labelGap),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _pickDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 50,
              padding: EdgeInsets.only(left: 20, right: iconRightPadding),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      Formatters.formDate(date),
                      style: AppTextStyles.fieldValue,
                    ),
                  ),
                  SvgPicture.asset(AppAssets.calendar, width: 20, height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
