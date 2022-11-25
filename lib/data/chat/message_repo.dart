import 'package:localstorage/localstorage.dart';
import 'package:openchat/model/chat/chat_message.dart';

class MessageRepo {
  List<ChatMessage> chatMessages = [];
  final LocalStorage _storage = LocalStorage('message_repo');

  addItem(ChatMessage chatMessage) {
    chatMessages.add(chatMessage);
    _saveToStorage();
  }

  _saveToStorage() {
    //_storage.setItem('message', chatMessages.toJSONEncodable());
  }

  clearStorage() async {
    await _storage.clear();
  }
}
