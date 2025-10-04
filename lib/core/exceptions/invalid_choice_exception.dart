/// Exception thrown when the user makes an invalid choice.
class InvalidChoiceException implements Exception {
  /// Error message describing the exception.
  final String message;

  /// Creates an [InvalidChoiceException] with an optional [message].
  InvalidChoiceException([this.message = 'Opción inválida']);

  @override
  String toString() => 'InvalidChoiceException: $message';
}