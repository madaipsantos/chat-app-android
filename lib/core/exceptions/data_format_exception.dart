/// Exception thrown when there is a data format error.
class DataFormatException implements Exception {
  /// Error message describing the exception.
  final String message;

  /// Creates a [DataFormatException] with an optional [message].
  DataFormatException([this.message = 'Error de formato de datos']);

  @override
  String toString() => 'DataFormatException: $message';
}