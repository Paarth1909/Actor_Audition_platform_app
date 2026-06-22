import 'package:actors_audition_platform_app/firebase_options.dart';
import 'package:actors_audition_platform_app/screens/homescreen.dart';
import 'package:actors_audition_platform_app/screens/loginpage.dart';
import 'package:actors_audition_platform_app/screens/roleselectionpage.dart';
import 'package:actors_audition_platform_app/screens/signup.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide User;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // SUPABASE INITIALIZATION
  // =========================
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://nghdjxlvupepapxwqidm.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5naGRqeGx2dXBlcGFweHdxaWRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3MzI3MzUsImV4cCI6MjA5NDMwODczNX0.RQm7S0BnFkKCr6CNhXBamjm2Qq1vES7Jfh-Pe4u4SBM',
    ),
  );

  // =========================
  // FIREBASE INITIALIZATION
  // =========================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // =========================
  // OPTIONAL AUTO SIGN OUT
  // =========================
  await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actors Audition Platform',
      debugShowCheckedModeBanner: false,

      // =========================
      // START SCREEN
      // =========================
      home: const HomeScreen(),

      // =========================
      // ROUTES
      // =========================
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const Loginpage(),
        '/signup': (context) => const Signup(),
        '/role': (context) => const RoleSelectionScreen(),
      },

      // =========================
      // THEME
      // =========================
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}