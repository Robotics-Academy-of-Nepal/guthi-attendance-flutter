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
    apiKey: 'AIzaSyDhZfxiFPMQ5f1wFruV9Is4uZoCHcT2Kcw',
    appId: '1:596726023508:web:6ac21bc450c4998aa734c1',
    messagingSenderId: '596726023508',
    projectId: 'attendance-ebe3c',
    authDomain: 'attendance-ebe3c.firebaseapp.com',
    storageBucket: 'attendance-ebe3c.firebasestorage.app',
    measurementId: 'G-MX6JJ2VR4L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_Ph3F7fsLZQCP4gxvjpnYdTDyS2aDX1Q',
    appId: '1:596726023508:android:d91a909bb30e4b33a734c1',
    messagingSenderId: '596726023508',
    projectId: 'attendance-ebe3c',
    storageBucket: 'attendance-ebe3c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKggfbwM8jFi7VEvB76j190XfoGB0QjrQ',
    appId: '1:596726023508:ios:640bda38d7c5082aa734c1',
    messagingSenderId: '596726023508',
    projectId: 'attendance-ebe3c',
    storageBucket: 'attendance-ebe3c.firebasestorage.app',
    iosBundleId: 'com.example.attendance2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBKggfbwM8jFi7VEvB76j190XfoGB0QjrQ',
    appId: '1:596726023508:ios:640bda38d7c5082aa734c1',
    messagingSenderId: '596726023508',
    projectId: 'attendance-ebe3c',
    storageBucket: 'attendance-ebe3c.firebasestorage.app',
    iosBundleId: 'com.example.attendance2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDhZfxiFPMQ5f1wFruV9Is4uZoCHcT2Kcw',
    appId: '1:596726023508:web:8d9bdc28a0375783a734c1',
    messagingSenderId: '596726023508',
    projectId: 'attendance-ebe3c',
    authDomain: 'attendance-ebe3c.firebaseapp.com',
    storageBucket: 'attendance-ebe3c.firebasestorage.app',
    measurementId: 'G-LJ51D7J7N7',
  );
}
