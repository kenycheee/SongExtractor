import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:songextractor/pages/home.dart';
import 'package:songextractor/auth/login_page.dart';
import 'firebase_options.dart'; // ← penting!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Pastikan hanya inisialisasi satu kali
    if (Firebase.apps.isEmpty) {
      print("🚀 Initializing Firebase with options...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      print("⚡ Firebase already initialized!");
    }
  } catch (e) {
    print("❌ Firebase init failed: $e");
  }

  runApp(SongExtractorApp());
}

class SongExtractorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,

      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
