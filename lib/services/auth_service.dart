import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<User?> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
    String phone,
    String address,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'role': 'user', // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Error en Firebase ${e.message}");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
}
