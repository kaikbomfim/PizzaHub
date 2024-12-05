// ignore_for_file: unnecessary_getters_setters
import 'package:google_sign_in/google_sign_in.dart';

class User {
  String? _name = "";
  String? get name => _name;
  set name(String? name) {
    _name = name;
  }

  String _email = "";
  String get email => _email;
  set email(String email) {
    _email = email;
  }

  User(String? name, String email) {
    _name = name;
    _email = email;
  }
}

class Authenticator {
  static Future<User> login() async {
    final gUser = await GoogleSignIn().signIn();
    final user = User(gUser!.displayName, gUser.email);

    return user;
  }

  static Future<User?> recoverUser() async {
    User? user;

    final gSignIn = GoogleSignIn();
    if (await gSignIn.isSignedIn()) {
      await gSignIn.signInSilently();

      final gUser = gSignIn.currentUser;
      if (gUser != null) {
        user = User(gUser.displayName, gUser.email);
      }
    }

    return user;
  }

  static Future<void> logout() async {
    await GoogleSignIn().signOut();
  }
}
