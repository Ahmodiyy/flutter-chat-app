import 'package:shared_preferences/shared_preferences.dart';

class ChatRepo {
  Future<List<String>?> getChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('chat_message');
  }

  Future<bool> isContainKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('chat_message');
  }

  void setChatMessages(List<String> newList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('chat_message', newList);
  }
}
