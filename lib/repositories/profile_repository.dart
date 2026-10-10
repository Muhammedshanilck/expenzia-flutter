import '../database/settings_database.dart';
import 'repository_exception.dart';

class ProfileRepository {
  ProfileRepository(this._database);

  final SettingsDatabase _database;

  static const String _nameKey = 'profile_name';
  static const String _onboardingKey = 'onboarding_done';
  static const String defaultName = 'Sahal Muhammed';

  Future<String> getName() async {
    try {
      return await _database.getValue(_nameKey) ?? defaultName;
    } catch (e) {
      throw RepositoryException('Could not load your profile.', e);
    }
  }

  Future<void> saveName(String name) async {
    try {
      await _database.setValue(_nameKey, name);
    } catch (e) {
      throw RepositoryException('Could not save your name.', e);
    }
  }

  Future<bool> isOnboardingDone() async {
    try {
      return await _database.getValue(_onboardingKey) == 'true';
    } catch (_) {
      // Showing onboarding again is harmless, so don't block the app.
      return false;
    }
  }

  Future<void> setOnboardingDone() async {
    try {
      await _database.setValue(_onboardingKey, 'true');
    } catch (_) {
      // Not critical: onboarding will just be shown again next launch.
    }
  }

  Future<void> clear() async {
    try {
      await _database.deleteAll();
    } catch (e) {
      throw RepositoryException('Could not clear your profile.', e);
    }
  }
}
