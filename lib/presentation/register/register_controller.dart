import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController extends StateNotifier<AsyncValue<void>> {
  RegisterController() : super(const AsyncValue.data(null));

  Future<void> register(String username) async {
    try {
      // set state to `loading` before starting the asynchronous work
      state = const AsyncValue.loading();
      // do the async work
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      state = const AsyncValue.data(null);
    } catch (e) {
      // if the payment failed, set the error state
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}
