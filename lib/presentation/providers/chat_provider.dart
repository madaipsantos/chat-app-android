import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/services/bible_service.dart';
import 'package:yes_no_app/infrastructure/models/bible_verse_model.dart';

class ChatProvider extends ChangeNotifier {
  final chatScrollController = ScrollController();

  List<Message> messageList = [
    Message(text: '¡Hola!', fromWho: FromWho.inteligentMessage),
    Message(
      text:
          'Soy tu asistente bíblico personal, siempre disponible. ¿Qué pasaje o versículo de la Biblia te gustaría consultar?',
      fromWho: FromWho.inteligentMessage,
    ),
  ];

  List<BibleVerseModel> resultados = [];
  bool aguardandoEscolha = false;

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    final newMessage = Message(text: text, fromWho: FromWho.userMessage);
    messageList.add(newMessage);

    if (aguardandoEscolha) {
      _processarEscolha(text);
    } else {
      _buscarVersiculos(text);
    }

    notifyListeners();
    moveScrollToBottom();
  }

  void _processarEscolha(String text) {
    int? escolha = int.tryParse(text);
    if (escolha != null && escolha > 0 && escolha <= resultados.length) {
      final v = resultados[escolha - 1];
      messageList.add(v.toMessageEntity());
      aguardandoEscolha = false;
      resultados = [];
    } else {
      messageList.add(
        Message(
          text: 'Escolha inválida. Digite um número válido da lista.',
          fromWho: FromWho.inteligentMessage,
        ),
      );
    }
  }

  void _buscarVersiculos(String query) {
    resultados = BibleService.buscar(query);

    if (resultados.isEmpty) {
      messageList.add(
        Message(
          text: 'Nenhum versículo encontrado para "$query".',
          fromWho: FromWho.inteligentMessage,
        ),
      );
    } else if (resultados.length == 1) {
      messageList.add(resultados[0].toMessageEntity());
    } else {
      String lista = "Encontrei ${resultados.length} versículos:\n";
      for (int i = 0; i < resultados.length; i++) {
        final v = resultados[i];
        lista += "${i + 1}. ${v.livro} ${v.capitulo}:${v.versiculo}\n";
      }
      messageList.add(
        Message(
          text: lista,
          fromWho: FromWho.inteligentMessage,
        ),
      );
      aguardandoEscolha = true;
    }
  }

  Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
