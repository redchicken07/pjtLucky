import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  static String? get currentUid {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static Future<String?> ensureSignedIn() async {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }
    final UserCredential credential = await auth.signInAnonymously();
    return credential.user?.uid;
  }
}
