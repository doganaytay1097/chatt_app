// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA9VlZ28k5khO5XxeGbMw-GqxyLqm3lRoc',
    appId: '1:265895612227:web:45bf0c21c14d2bb3bca9f6',
    messagingSenderId: '265895612227',
    projectId: 'chatappflutter-7696a',
    authDomain: 'chatappflutter-7696a.firebaseapp.com',
    storageBucket: 'chatappflutter-7696a.appspot.com',
    measurementId: 'G-J1R5DHPNXL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAe4S6C5JEc4DbHuBhmZtsFAGQr9uEcLs8',
    appId: '1:265895612227:android:671f3aa507b04672bca9f6',
    messagingSenderId: '265895612227',
    projectId: 'chatappflutter-7696a',
    storageBucket: 'chatappflutter-7696a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0AAlLyEjAsb5_ANjGn7FTKTd9PC5hrjc',
    appId: '1:265895612227:ios:8fe38cf3bc46e555bca9f6',
    messagingSenderId: '265895612227',
    projectId: 'chatappflutter-7696a',
    storageBucket: 'chatappflutter-7696a.appspot.com',
    iosBundleId: 'com.example.chattApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB0AAlLyEjAsb5_ANjGn7FTKTd9PC5hrjc',
    appId: '1:265895612227:ios:8fe38cf3bc46e555bca9f6',
    messagingSenderId: '265895612227',
    projectId: 'chatappflutter-7696a',
    storageBucket: 'chatappflutter-7696a.appspot.com',
    iosBundleId: 'com.example.chattApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA9VlZ28k5khO5XxeGbMw-GqxyLqm3lRoc',
    appId: '1:265895612227:web:f4ddc1285621526fbca9f6',
    messagingSenderId: '265895612227',
    projectId: 'chatappflutter-7696a',
    authDomain: 'chatappflutter-7696a.firebaseapp.com',
    storageBucket: 'chatappflutter-7696a.appspot.com',
    measurementId: 'G-53WQQQ3DF5',
  );
}
