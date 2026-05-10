import 'package:actors_audition_platform_app/roleselectionpage.dart';
import 'package:flutter/material.dart';
import 'package:actors_audition_platform_app/loginpage.dart';
import 'package:actors_audition_platform_app/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 👇 Start app from Login Page
      home: Loginpage(),

      // 👇 Optional but BEST practice
      routes: {
        '/login': (context) => Loginpage(),
        '/signup': (context) => Signup(),
        '/role': (context) => RoleSelectionScreen(),
      },
    );
  }
}
