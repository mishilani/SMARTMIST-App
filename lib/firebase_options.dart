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
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBnY5023rHlC4cefOhI-YQWEa7gZBdO5kc',
    appId: '1:155991770829:web:3603521511d7c721444b84',
    messagingSenderId: '155991770829',
    projectId: 'smartmist-it31',
    authDomain: 'smartmist-it31.firebaseapp.com',
    databaseURL:
        'https://smartmist-it31-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smartmist-it31.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB49vyl7s_RTNAVavpdnjp9kPGpBbCMM3U',
    appId: '1:155991770829:android:b71062c3ef09eac4444b84',
    messagingSenderId: '155991770829',
    projectId: 'smartmist-it31',
    databaseURL:
        'https://smartmist-it31-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smartmist-it31.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAeTE7_ABUcYOQj6NOcm-AUl3Dymc0bnKI',
    appId: '1:155991770829:ios:b761f5a66e9f71ad444b84',
    messagingSenderId: '155991770829',
    projectId: 'smartmist-it31',
    databaseURL:
        'https://smartmist-it31-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smartmist-it31.firebasestorage.app',
    iosBundleId: 'com.smartmist.smartmistApp',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAeTE7_ABUcYOQj6NOcm-AUl3Dymc0bnKI',
    appId: '1:155991770829:ios:b761f5a66e9f71ad444b84',
    messagingSenderId: '155991770829',
    projectId: 'smartmist-it31',
    databaseURL:
        'https://smartmist-it31-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smartmist-it31.firebasestorage.app',
    iosBundleId: 'com.smartmist.smartmistApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBnY5023rHlC4cefOhI-YQWEa7gZBdO5kc',
    appId: '1:155991770829:web:f6b053095ec75ef7444b84',
    messagingSenderId: '155991770829',
    projectId: 'smartmist-it31',
    authDomain: 'smartmist-it31.firebaseapp.com',
    databaseURL:
        'https://smartmist-it31-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smartmist-it31.firebasestorage.app',
  );
}
