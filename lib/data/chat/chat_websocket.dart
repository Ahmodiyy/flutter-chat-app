import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../model/chat/chat_message.dart';

class ChatWebSocket {
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080/name'),
  );
  static ChatWebSocket? _chatWebSocket;

  ChatWebSocket._();

  static ChatWebSocket getInstance() {
    return _chatWebSocket ??= ChatWebSocket._();
  }

  void sendMessage(String username, String message) async {
    _channel.sink.add(
      jsonEncode({
        'username': username,
        'message': message,
      }),
    );
  }

  void closeWebSocket() {
    _channel.sink.close();
  }

  Stream getMessageStream() {
    return _channel.stream;
  }
}
