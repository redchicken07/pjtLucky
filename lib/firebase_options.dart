import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      final String apiKey = const String.fromEnvironment('FIREBASE_API_KEY');
      final String appId = const String.fromEnvironment('FIREBASE_APP_ID');
      final String messagingSenderId = const String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
      );
      final String projectId = const String.fromEnvironment(
        'FIREBASE_PROJECT_ID',
      );

      if (apiKey.isEmpty ||
          appId.isEmpty ||
          messagingSenderId.isEmpty ||
          projectId.isEmpty) {
        throw UnsupportedError(
          'Missing Firebase web dart-defines. '
          'Set FIREBASE_API_KEY, FIREBASE_APP_ID, FIREBASE_MESSAGING_SENDER_ID, '
          'and FIREBASE_PROJECT_ID before building.',
        );
      }

      return FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
        storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
        measurementId: const String.fromEnvironment('FIREBASE_MEASUREMENT_ID'),
      );
    }

    throw UnsupportedError(
      'Mobile Firebase settings are not configured in this repository yet.',
    );
  }
}
