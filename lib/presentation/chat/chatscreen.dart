import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openchat/data/chat/message_repo.dart';
import 'package:openchat/model/chat/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/chat/chat_websocket.dart';

final messageStreamProvider = StreamProvider.autoDispose<dynamic>((ref) {
  return ChatWebSocket.getInstance().getMessageStream();
});
final messageListProvider =
    FutureProvider.autoDispose<List<String>?>((ref) async {
  final message = await ref.watch(messageStreamProvider.future);
  final prefs = await SharedPreferences.getInstance();
  print('message ${prefs.getStringList('chat_message')}');

  List<String>? previousMessageList = prefs.getStringList('chat_message');
  List<String> messageList = [message.toString()];
  List<String> newList = [];
  if (previousMessageList != null) {
    newList = List.from(previousMessageList)..addAll(messageList);
  } else {
    newList.addAll(messageList);
  }
  await prefs.setStringList('chat_message', newList);
  return newList;
});

class ChatScreen extends ConsumerStatefulWidget {
  static String id = 'chatscreen';
  const ChatScreen({
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  ScrollController scrollController = ScrollController();
  late TextEditingController _controller;
  bool needScroll = false;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    ChatWebSocket.getInstance().closeWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageList = ref.watch(messageListProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: const [
                  Icon(Icons.message, color: Colors.deepPurple),
                  Flexible(
                    child: FractionallySizedBox(
                      widthFactor: 0.01,
                    ),
                  ),
                  Text('Open Chat'),
                ],
              ),
            ),
            buildDivider(),
            Expanded(
              flex: 10,
              child: Row(
                children: [
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xff131928),
                                  Color(0xff161E2E),
                                  Color(0xff191D2A),
                                  Color(0xff161825),
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Welcome to Open Chat',
                                      style: TextStyle(
                                        color: Color(0xff3D88CD),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      'We can now freely collaborate on our project. Any question about the documentation or project? Please feel free to discuss any issue.',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color:
                                              Colors.white60.withOpacity(0.3)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 10,
                            child: messageList.when(data: (data) {
                              List<ChatMessage>? chatMessageList =
                                  data?.map((element) {
                                final data = jsonDecode(element);
                                return ChatMessage(
                                    data['username'], data['message']);
                              }).toList();
                              return ListView.builder(
                                padding: const EdgeInsets.all(20),
                                controller: scrollController,
                                itemCount: chatMessageList?.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    child:
                                        Text(chatMessageList![index].message),
                                  );
                                },
                              );
                            }, error: (obj, stake) {
                              return const Text('Service unavailable');
                            }, loading: () {
                              return Text('');
                            })),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 10,
                                child: Form(
                                  child: TextFormField(
                                    controller: _controller,
                                    decoration: const InputDecoration(
                                        labelText: 'Send a message'),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  onPressed: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    if (_controller.text.isNotEmpty) {
                                      ChatWebSocket.getInstance().sendMessage(
                                        prefs.getString('username')!,
                                        _controller.text,
                                      );
                                    }

                                    await Future.delayed(
                                        const Duration(milliseconds: 100));
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((_) {
                                      scrollController.animateTo(
                                          scrollController
                                              .position.maxScrollExtent,
                                          duration: Duration(milliseconds: 1),
                                          curve: Curves.fastOutSlowIn);
                                    });
                                  },
                                  icon: const Icon(Icons.send),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildDivider() {
    return const Divider(
      thickness: 1,
      color: Colors.white12,
    );
  }
}
