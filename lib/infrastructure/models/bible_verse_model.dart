import 'package:equatable/equatable.dart';
import 'package:yes_no_app/domain/entities/message.dart';

/// Modelo que representa um versículo bíblico.
/// 
/// Fornece métodos para converter de/para JSON e para criar uma entidade [Message].
class BibleVerseModel extends Equatable {
  final String livro;
  final int capitulo;
  final int versiculo;
  final String texto;

  const BibleVerseModel({
    required this.livro,
    required this.capitulo,
    required this.versiculo,
    required this.texto,
  });

  /// Cria uma instância de [BibleVerseModel] a partir de um mapa JSON.
  factory BibleVerseModel.fromJson(Map<String, dynamic> json) => BibleVerseModel(
        livro: json["livro"] as String,
        capitulo: json["capitulo"] as int,
        versiculo: json["versiculo"] as int,
        texto: json["texto"] as String,
      );

  /// Converte este modelo para um mapa JSON.
  Map<String, dynamic> toJson() => {
        "livro": livro,
        "capitulo": capitulo,
        "versiculo": versiculo,
        "texto": texto,
      };

  /// Formata a referência bíblica (ex: "João 3:16").
  String get reference => '$livro $capitulo:$versiculo';

  /// Converte este modelo para uma entidade [Message].
  Message toMessageEntity() => Message(
        text: '$reference - $texto',
        fromWho: FromWho.systemChatMessage,
      );

  @override
  List<Object?> get props => [livro, capitulo, versiculo, texto];
}
