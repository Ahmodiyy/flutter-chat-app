import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chatscreen';
  const ChatScreen({
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _controller;
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/name'),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                  const Text(
                                    'Welcome to Open Chat',
                                    style: TextStyle(
                                      color: Color(0xff3D88CD),
                                    ),
                                  ),
                                  Text(
                                    'We can now freely collaborate on our project. Any question about the documentation or project? Please feel free to discuss any issue.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white60.withOpacity(0.3)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: StreamBuilder(
                            stream: _channel.stream,
                            builder: (context, snapshot) {
                              print(snapshot.error);
                              return Text(
                                  snapshot.hasData ? '${snapshot.data}' : '');
                            },
                          ),
                        ),
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
                                  onPressed: () {},
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

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      print('sending message');
      _channel.sink.add(_controller.text);
    }
  }
}
