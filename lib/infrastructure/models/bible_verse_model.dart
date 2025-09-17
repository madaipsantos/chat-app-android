import 'package:yes_no_app/domain/entities/message.dart';

class BibleVerseModel {
  final String livro;
  final int capitulo;
  final int versiculo;
  final String texto;

  BibleVerseModel({
    required this.livro,
    required this.capitulo,
    required this.versiculo,
    required this.texto,
  });

  factory BibleVerseModel.fromJson(Map<String, dynamic> json) => BibleVerseModel(
        livro: json["livro"],
        capitulo: json["capitulo"],
        versiculo: json["versiculo"],
        texto: json["texto"],
      );

  Map<String, dynamic> toJson() => {
        "livro": livro,
        "capitulo": capitulo,
        "versiculo": versiculo,
        "texto": texto,
      };

  Message toMessageEntity() => Message(
        text: "$livro $capitulo:$versiculo - $texto",
        fromWho: FromWho.systemChatMessage,
      );
}
