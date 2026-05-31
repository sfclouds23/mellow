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
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBqI_PCVJgUyWvUZPTfYu8ZR5XZ3aJ7w4o',
    appId: '1:834288145179:web:b25e658382bacc0a2a39be',
    messagingSenderId: '834288145179',
    projectId: 'mellow-13c1c',
    authDomain: 'mellow-13c1c.firebaseapp.com',
    storageBucket: 'mellow-13c1c.firebasestorage.app',
    measurementId: 'G-ZRQ8FK9TJG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqI_PCVJgUyWvUZPTfYu8ZR5XZ3aJ7w4o',
    appId: '1:834288145179:android:b25e658382bacc0a2a39be',
    messagingSenderId: '834288145179',
    projectId: 'mellow-13c1c',
    storageBucket: 'mellow-13c1c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBqI_PCVJgUyWvUZPTfYu8ZR5XZ3aJ7w4o',
    appId: '1:834288145179:ios:b25e658382bacc0a2a39be',
    messagingSenderId: '834288145179',
    projectId: 'mellow-13c1c',
    storageBucket: 'mellow-13c1c.firebasestorage.app',
    iosBundleId: 'com.example.mellow',
  );
}