/// A database error turned into a message that can be shown to the user.
class RepositoryException implements Exception {
  RepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'RepositoryException: $message ($cause)';
}
