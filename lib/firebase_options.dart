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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running "flutterfire configure"',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCbtWIZxA_0dky7Njmdwtd5ZSuKwcQPOnQ',
    appId: '1:675177292569:android:6cece718b2399eba3d9b88',
    messagingSenderId: '675177292569',
    projectId: 'feedback-app-ed175',
    authDomain: 'feedback-app-ed175.firebaseapp.com',
    storageBucket: 'feedback-app-ed175.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCbtWIZxA_0dky7Njmdwtd5ZSuKwcQPOnQ',
    appId: '1:675177292569:android:6cece718b2399eba3d9b88',
    messagingSenderId: '675177292569',
    projectId: 'feedback-app-ed175',
    storageBucket: 'feedback-app-ed175.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCbtWIZxA_0dky7Njmdwtd5ZSuKwcQPOnQ',
    appId: '1:675177292569:android:6cece718b2399eba3d9b88',
    messagingSenderId: '675177292569',
    projectId: 'feedback-app-ed175',
    storageBucket: 'feedback-app-ed175.firebasestorage.app',
    iosBundleId: 'com.feedback_app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCbtWIZxA_0dky7Njmdwtd5ZSuKwcQPOnQ',
    appId: '1:675177292569:android:6cece718b2399eba3d9b88',
    messagingSenderId: '675177292569',
    projectId: 'feedback-app-ed175',
    storageBucket: 'feedback-app-ed175.firebasestorage.app',
    iosBundleId: 'com.feedback_app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCbtWIZxA_0dky7Njmdwtd5ZSuKwcQPOnQ',
    appId: '1:675177292569:android:6cece718b2399eba3d9b88',
    messagingSenderId: '675177292569',
    projectId: 'feedback-app-ed175',
    storageBucket: 'feedback-app-ed175.firebasestorage.app',
  );
}
