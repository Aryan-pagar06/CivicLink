// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDuwdPAylkCj8yUOli7_Xk76GYzMd_Blj0",
    authDomain: "civiclink-8ca46.firebaseapp.com",
    projectId: "civiclink-8ca46",
    storageBucket: "civiclink-8ca46.firebasestorage.app",
    messagingSenderId: "1058297290954",
    appId: "1:1058297290954:web:b6080e7c5f4b0ba5579433",
    measurementId: "G-69L06VZQQ6",
  );
}