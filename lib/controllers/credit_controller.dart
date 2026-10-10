import 'package:flutter/foundation.dart';

import '../models/credit.dart';
import '../repositories/credit_repository.dart';
import '../repositories/repository_exception.dart';

class CreditController extends ChangeNotifier {
  CreditController(this._repository);

  final CreditRepository _repository;

  List<Credit> _credits = [];
  String? _errorMessage;

  List<Credit> get credits => List.unmodifiable(_credits);
  String? get errorMessage => _errorMessage;

  Future<void> loadCredits() async {
    try {
      _credits = await _repository.getCredits();
      _errorMessage = null;
    } on RepositoryException catch (e) {
      _errorMessage = e.message;
    }
    notifyListeners();
  }

  Future<void> addCredit(Credit credit) async {
    await _repository.addCredit(credit);
    await loadCredits();
  }

  Future<void> deleteCredit(Credit credit) async {
    if (credit.id == null) return;
    await _repository.deleteCredit(credit.id!);
    await loadCredits();
  }

  Future<void> deleteAll() async {
    await _repository.deleteAll();
    await loadCredits();
  }
}
