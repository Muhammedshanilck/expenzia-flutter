/// Form validators. Each returns an error message, or null when valid.
class Validators {
  Validators._();

  static const double maxAmount = 10000000; // ₹ 1 crore

  static String? requiredText(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    if (value.trim().length > 50) {
      return '$field must be 50 characters or less';
    }
    return null;
  }

  static String? amount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Amount is required';
    }
    final parsed = parseAmount(text);
    if (parsed == null) {
      return 'Enter a valid number, e.g. 250.50';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than zero';
    }
    if (parsed > maxAmount) {
      return 'Amount is too large';
    }
    return null;
  }

  /// Accepts "250", "250.5" or "1,250.50". Returns null if not a valid
  /// number with at most two decimal places.
  static double? parseAmount(String value) {
    final text = value.replaceAll(',', '').trim();
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) {
      return null;
    }
    return double.tryParse(text);
  }

  static String? description(String? value) {
    if (value != null && value.trim().length > 200) {
      return 'Description must be 200 characters or less';
    }
    return null;
  }
}
