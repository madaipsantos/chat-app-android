/// Enum representing the sender of a message.
enum FromWho {
  userChatMessage,
  systemChatMessage,
  verseMessage,
}

/// Entity representing a chat message.
class Message {
  /// The message text.
  final String text;

  /// Optional image URL associated with the message.
  final String? imageUrl;

  /// Who sent the message.
  final FromWho fromWho;

  /// Creates a [Message] entity.
  Message({
    required this.text,
    this.imageUrl,
    required this.fromWho,
  });
}