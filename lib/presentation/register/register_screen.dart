import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:openchat/presentation/register/register_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat/chatscreen.dart';

final registerControllerProvider =
    StateNotifierProvider<RegisterController, AsyncValue<void>>((ref) {
  return RegisterController();
});

class RegisterScreen extends ConsumerStatefulWidget {
  static String id = 'registerscreen';
  const RegisterScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      registerControllerProvider,
      (_, state) => state.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Center(child: Text(error.toString()))),
          );
        },
      ),
    );
    ref.listen<AsyncValue<void>>(
      registerControllerProvider,
      (_, state) => state.whenOrNull(
        data: (data) => Navigator.pushReplacementNamed(context, ChatScreen.id),
      ),
    );
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Center(
            child: SizedBox(
              width: 400,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: _name,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        hintText: 'Username',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Flexible(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ref
                              .read(registerControllerProvider.notifier)
                              .register(_name.text);
                        }
                      },
                      child: const Text('register'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
