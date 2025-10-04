import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';
import 'package:asistente_biblico/core/exceptions/data_format_exception.dart';
import 'package:equatable/equatable.dart';
import 'package:asistente_biblico/domain/entities/message.dart';

/// Model representing a Bible verse.
///
/// Provides methods for JSON serialization and conversion to a [Message] entity.
class BibleVerseModel extends Equatable {
  final String livro;
  final int capitulo;
  final int versiculo;
  final String texto;

  /// Creates a [BibleVerseModel] instance.
  const BibleVerseModel({
    required this.livro,
    required this.capitulo,
    required this.versiculo,
    required this.texto,
  });

  /// Creates a [BibleVerseModel] from a JSON map.
  ///
  /// Throws [DataFormatException] if required fields are missing or types are incorrect.
  factory BibleVerseModel.fromJson(Map<String, dynamic> json) {
    try {
      if (!json.containsKey('livro') ||
          !json.containsKey('capitulo') ||
          !json.containsKey('versiculo') ||
          !json.containsKey('texto')) {
        throw DataFormatException(ChatMessagesConstants.errorMissingFields);
      }
      final livro = json['livro'];
      final capitulo = json['capitulo'];
      final versiculo = json['versiculo'];
      final texto = json['texto'];
      if (livro is! String || capitulo is! int || versiculo is! int || texto is! String) {
        throw DataFormatException(ChatMessagesConstants.errorWrongTypes);
      }
      return BibleVerseModel(
        livro: livro,
        capitulo: capitulo,
        versiculo: versiculo,
        texto: texto,
      );
    } catch (_) {
      throw DataFormatException(ChatMessagesConstants.errorFormatVerse);
    }
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() => {
        "livro": livro,
        "capitulo": capitulo,
        "versiculo": versiculo,
        "texto": texto,
      };

  /// Returns the formatted Bible reference (e.g., "John 3:16").
  String get reference => '$livro $capitulo:$versiculo';

  /// Converts this model to a [Message] entity.
  Message toMessageEntity() => Message(
        text: '$reference - $texto',
        fromWho: FromWho.systemChatMessage,
      );

  @override
  List<Object?> get props => [livro, capitulo, versiculo, texto];
}