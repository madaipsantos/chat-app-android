import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/services/bible_service.dart';
import 'package:yes_no_app/infrastructure/models/bible_verse_model.dart';

class ChatProvider extends ChangeNotifier {
  final chatScrollController = ScrollController();
  bool aguardandoRespostaNovaBusca = false;

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

  // Garantia de carregamento
  bool _jsonCarregado = true; // Como já carregamos no main, já pode ser true

  Future<void> sendMessage(String text) async {
    if (!_jsonCarregado) {
      messageList.add(Message(
        text: "Carregando os versículos, por favor aguarde...",
        fromWho: FromWho.inteligentMessage,
      ));
      notifyListeners();
      return;
    }

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
  // Verifica se é uma resposta sim/não para nova busca
  if (aguardandoRespostaNovaBusca) {
    if (text.toLowerCase().contains('sim') || 
        text.toLowerCase().contains('ok') || 
        text.toLowerCase().contains('quero')) {
      aguardandoEscolha = false;
      aguardandoRespostaNovaBusca = false;
      resultados = [];
      messageList.add(
        Message(
          text: 'Ótimo! Pode fazer uma nova busca.',
          fromWho: FromWho.inteligentMessage,
        ),
      );
      return;
    } else {
      aguardandoRespostaNovaBusca = false;
      String lista = "Ok, aqui estão os versículos novamente:\n";
      for (int i = 0; i < resultados.length; i++) {
        final v = resultados[i];
        lista += "${i + 1}. ${v.livro} ${v.capitulo}:${v.versiculo}\n";
      }
      messageList.add(
        Message(
          text: lista + "\nPor favor, escolha um número da lista.",
          fromWho: FromWho.inteligentMessage,
        ),
      );
      return;
    }
  }

  // Tenta converter a entrada para número
  int? escolha = int.tryParse(text);
  
  if (escolha != null && escolha > 0 && escolha <= resultados.length) {
    final v = resultados[escolha - 1];
    messageList.add(v.toMessageEntity());
    aguardandoEscolha = false;
    resultados = [];
  } else {
    messageList.add(
      Message(
        text: 'Essa não é uma opção válida. Você gostaria de fazer uma nova busca?',
        fromWho: FromWho.inteligentMessage,
      ),
    );
    aguardandoRespostaNovaBusca = true;
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
      String lista = "Encontrei ${resultados.length} versículos:\n\n";
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
