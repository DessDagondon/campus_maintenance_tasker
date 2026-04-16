import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDksiWWgQPBdXgiTc5XutIPctKkAz9sf4Q',
    appId: '1:65307652271:android:2e0c38bf44f249698d245a',
    messagingSenderId: '65307652271',
    projectId: 'campusmaintenance-f1b6e',
    storageBucket: 'campusmaintenance-f1b6e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '65307652271',
    projectId: 'campusmaintenance-f1b6e',
    storageBucket: 'campusmaintenance-f1b6e.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_MACOS_API_KEY',
    appId: 'REPLACE_WITH_MACOS_APP_ID',
    messagingSenderId: '65307652271',
    projectId: 'campusmaintenance-f1b6e',
    storageBucket: 'campusmaintenance-f1b6e.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_WINDOWS_API_KEY',
    appId: 'REPLACE_WITH_WINDOWS_APP_ID',
    messagingSenderId: '65307652271',
    projectId: 'campusmaintenance-f1b6e',
    storageBucket: 'campusmaintenance-f1b6e.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_WITH_LINUX_API_KEY',
    appId: 'REPLACE_WITH_LINUX_APP_ID',
    messagingSenderId: '65307652271',
    projectId: 'campusmaintenance-f1b6e',
    storageBucket: 'campusmaintenance-f1b6e.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAeyznTUkNw8zYAuVOv967qaWfKMsIFsUs',
    appId: '1:65307652271:web:840c906d3b3003be8d245a',
    messagingSenderId: '65307652271',
    projectId: 'campusmaintenance-f1b6e',
    storageBucket: 'campusmaintenance-f1b6e.firebasestorage.app',
    authDomain: 'campusmaintenance-f1b6e.firebaseapp.com',
    measurementId: 'G-EC11SCM51C',
  );
}
