/// Exception thrown when a Bible verse search fails.
class BibleSearchException implements Exception {
  /// Error message describing the exception.
  final String message;

  /// Creates a [BibleSearchException] with an optional [message].
  BibleSearchException([this.message = 'Error al buscar versículos']);

  @override
  String toString() => 'BibleSearchException: $message';
}