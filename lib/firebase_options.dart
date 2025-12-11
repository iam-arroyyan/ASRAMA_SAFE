// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCz1xA288877fHk1ZWv542ZpRGKAfJbJ6s',
    appId: '1:242647940418:web:9243c655e5e36f14d05cdb',
    messagingSenderId: '242647940418',
    projectId: 'asrama-safe',
    databaseURL: 'https://asrama-safe-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'asrama-safe.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC2NA1pg0nV_OzbHUDzb9UWJR6V2ODq5bo',
    appId: '1:242647940418:android:ca779b35370b7585d05cdb',
    messagingSenderId: '242647940418',
    projectId: 'asrama-safe',
    databaseURL: 'https://asrama-safe-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'asrama-safe.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA6MpX-glDNwnMPrgwvb4PxwKWFN9CmQYI',
    appId: '1:242647940418:ios:a27a84268e272989d05cdb',
    messagingSenderId: '242647940418',
    projectId: 'asrama-safe',
    databaseURL: 'https://asrama-safe-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'asrama-safe.firebasestorage.app',
    iosBundleId: 'com.example.asramaSafe',
  );
}
