import 'package:flutter/foundation.dart';

import '../repositories/profile_repository.dart';
import '../repositories/repository_exception.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);

  final ProfileRepository _repository;

  String _name = ProfileRepository.defaultName;

  String get name => _name;

  Future<void> loadProfile() async {
    try {
      _name = await _repository.getName();
    } on RepositoryException {
      _name = ProfileRepository.defaultName;
    }
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    await _repository.saveName(name);
    _name = name;
    notifyListeners();
  }

  Future<bool> isOnboardingDone() => _repository.isOnboardingDone();

  Future<void> completeOnboarding() => _repository.setOnboardingDone();

  /// Removes the saved name and the onboarding flag.
  Future<void> clear() async {
    await _repository.clear();
    _name = ProfileRepository.defaultName;
    notifyListeners();
  }
}
