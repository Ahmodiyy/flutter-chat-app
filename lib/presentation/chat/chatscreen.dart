import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openchat/model/chat/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/chat/chat_repo.dart';
import '../../data/chat/chat_websocket.dart';

final messageStreamProvider = StreamProvider.autoDispose<dynamic>((ref) {
  return ChatWebSocket.getInstance().getMessageStream();
});

final isFirstLoadProvider = StateProvider<bool>((ref) {
  return true;
});

final messageListProvider =
    FutureProvider.autoDispose<List<String>?>((ref) async {
  List<String> newList = [];
  ChatRepo chatRepo = ChatRepo();
  bool isContainKey = await chatRepo.isContainKey();
  if (!isContainKey) {
    final message = await ref.watch(messageStreamProvider.future);
    newList.add(message.toString());
    chatRepo.setChatMessages(newList);
    return newList;
  } else {
    return chatRepo.getChatMessages();
  }

  // print('2 ${ref.watch(isFirstLoadProvider)}');
  // if (!ref.watch(isFirstLoadProvider)) {
  //   final message = await ref.watch(messageStreamProvider.future);
  //   List<String>? chatMessages = await chatRepo.getChatMessages();
  //   List<String> messageList = [message.toString()];
  //   print('item 1: ${chatMessages?.length}');
  //   print('item 2: ${messageList.length}');
  //   newList = List.from(chatMessages!)..addAll(messageList);
  //
  //   chatRepo.setChatMessages(newList);
  // }
  //
  // return newList;
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
  late String? username;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    getUsername();
    scrollController.addListener(() {
      print('inside listener');
      if (scrollController.position.atEdge) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    ChatWebSocket.getInstance().closeWebSocket();
    super.dispose();
  }

  void getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((duration) {
    //   print(duration.inSeconds.toString());
    //   print('scroll controller ${scrollController.positions.isNotEmpty}');
    //   if (scrollController.hasClients) {
    //     scrollController.jumpTo(scrollController.position.maxScrollExtent);
    //   }
    // });

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
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
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
                              return Scrollbar(
                                controller: scrollController,
                                thumbVisibility: true,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(20),
                                  controller: scrollController,
                                  itemCount: chatMessageList?.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment: username ==
                                              chatMessageList![index].username
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Material(
                                          color: const Color(0xff110F19),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: username ==
                                                      chatMessageList[index]
                                                          .username
                                                  ? Colors.deepPurple
                                                  : const Color(0xff181729),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.elliptical(15, 10),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 3),
                                            margin: const EdgeInsets.all(5.0),
                                            child: Text(
                                              chatMessageList[index].message,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  letterSpacing: 2,
                                                  wordSpacing: 2,
                                                  height: 2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            }, error: (obj, stake) {
                              return const Center(
                                  child: Text('Service unavailable'));
                            }, loading: () {
                              return Container();
                            })),
                        Expanded(
                          flex: 2,
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
                                    if (_controller.text.isNotEmpty) {
                                      ChatWebSocket.getInstance().sendMessage(
                                        username!,
                                        _controller.text,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.send,
                                      color: Colors.deepPurple),
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
