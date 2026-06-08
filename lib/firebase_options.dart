import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(_message);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return android;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase options are not configured for Fuchsia.',
        );
    }
  }

    static const String _message =
      'Run "flutterfire configure" to generate this file.';

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrZqxMr7hTmaqT6wo6KEzI4kNKAKzs-Cc',
    appId: '1:729650918863:android:845655bb76161b8e24ceba',
    messagingSenderId: '729650918863',
    projectId: 'aicar-580d8',
    storageBucket: 'aicar-580d8.firebasestorage.app',
  );

}