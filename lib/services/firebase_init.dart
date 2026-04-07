import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import 'auth_service.dart';

class FirebaseInit {
  static Future<void>? _bootstrap;
  static bool _isReady = false;
  static bool _isConfigured = false;
  static String _statusMessage = 'Firebase 초기화 전';

  static Future<void> initialize() {
    return _bootstrap ??= _initializeInternal();
  }

  static bool get isReady => _isReady;
  static bool get isConfigured => _isConfigured;
  static String get statusMessage => _statusMessage;

  static Future<void> _initializeInternal() async {
    try {
      final FirebaseOptions options = DefaultFirebaseOptions.currentPlatform;
      _isConfigured = true;
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
      _isReady = true;
      final String? uid = await AuthService.ensureSignedIn();
      _statusMessage = uid == null
          ? 'Firebase 초기화는 되었지만 익명 로그인이 준비되지 않았습니다.'
          : 'Firebase 연결됨';
    } catch (_) {
      _isConfigured = false;
      _isReady = false;
      _statusMessage =
          'Firebase 미설정 상태입니다. flutterfire configure 이후 생성된 '
          'firebase_options.dart로 교체하면 실서버 저장이 활성화됩니다.';
    }
  }
}
