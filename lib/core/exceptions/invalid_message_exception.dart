/// Exception thrown when the user sends an invalid message.
class InvalidMessageException implements Exception {
  /// Error message describing the exception.
  final String message;

  /// Creates an [InvalidMessageException] with an optional [message].
  InvalidMessageException([this.message = 'Mensaje inválido']);

  @override
  String toString() => 'InvalidMessageException: $message';
}