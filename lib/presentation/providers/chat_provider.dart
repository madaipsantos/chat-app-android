import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
 
  List<Message> messageList = [
    Message(text: 'Hola', fromWho: FromWho.userMessage),
    Message(text: 'Ya regresate del trabajo?', fromWho: FromWho.userMessage),   
  ];

  Future<void> sendMessage(String text) async {

    final newMessage = Message(text: text, fromWho: FromWho.userMessage);
    messageList.add(newMessage);
    notifyListeners();
  }

}