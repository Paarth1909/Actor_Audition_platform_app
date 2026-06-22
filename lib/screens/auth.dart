import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final _db = FirebaseFirestore.instance;

Future<User?> signup(
  String email,
  String password,
  String role,
) async {
  try {
    UserCredential userCredential =
        await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      // Save user profile with role to Firestore immediately
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'role': role,
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    return user;
  } on FirebaseAuthException catch (e) {
    debugPrint(e.message);
    return null;
  }
}

Future<User?> login(
  String email,
  String password,
) async {
  try {
    UserCredential userCredential =
        await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    debugPrint(e.message);
    return null;
  }
}