import '../database/credit_database.dart';
import '../models/credit.dart';
import 'repository_exception.dart';

class CreditRepository {
  CreditRepository(this._database);

  final CreditDatabase _database;

  Future<List<Credit>> getCredits() async {
    try {
      return await _database.getAll();
    } catch (e) {
      throw RepositoryException('Could not load your saved list.', e);
    }
  }

  Future<void> addCredit(Credit credit) async {
    try {
      await _database.insert(credit);
    } catch (e) {
      throw RepositoryException('Could not save the credit.', e);
    }
  }

  Future<void> deleteCredit(int id) async {
    try {
      await _database.delete(id);
    } catch (e) {
      throw RepositoryException('Could not delete the credit.', e);
    }
  }

  Future<void> deleteAll() async {
    try {
      await _database.deleteAll();
    } catch (e) {
      throw RepositoryException('Could not clear your saved list.', e);
    }
  }
}
