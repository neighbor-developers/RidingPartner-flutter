// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4CVWEZ-Vs-NUFLmoNDwGuoD4_Z4vd46w',
    appId: '1:93312283448:android:4860c82a321623b54107cd',
    messagingSenderId: '93312283448',
    projectId: 'riding-partner-flutter',
    storageBucket: 'riding-partner-flutter.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBn1JwEpwqkM0oj9ZBNQXlZ3nOsv7yVXPg',
    appId: '1:93312283448:ios:8d58951ef8bcd8ce4107cd',
    messagingSenderId: '93312283448',
    projectId: 'riding-partner-flutter',
    databaseURL:
        'https://riding-partner-flutter-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'riding-partner-flutter.appspot.com',
    androidClientId:
        '93312283448-26i7napgb7r6tvj7dkkmjdj5p2md1bq1.apps.googleusercontent.com',
    iosClientId:
        '93312283448-78dimjfpvokduhv244k8i07fd2b0qfrc.apps.googleusercontent.com',
    iosBundleId: 'com.neighbor.ridingpartner.ridingpartnerFlutter',
  );
}
