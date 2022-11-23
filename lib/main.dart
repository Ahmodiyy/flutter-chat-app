import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openchat/presentation/chat/chatscreen.dart';
import 'package:openchat/presentation/register/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? seen = prefs.getString('username');
  runApp(ProviderScope(
      child: MyApp(
    username: seen,
  )));
}

class MyApp extends StatelessWidget {
  final String? username;
  const MyApp({super.key, required this.username});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.

        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xff110F19),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white70),
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Color(0xff19182A),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(
              15,
            )),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(
              15,
            )),
          ),
        ),
      ),
      initialRoute: username == null ? RegisterScreen.id : ChatScreen.id,
      routes: {
        RegisterScreen.id: (context) => const RegisterScreen(),
        ChatScreen.id: (context) => const ChatScreen(),
      },
    );
  }
}
