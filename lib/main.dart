import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:votacionesappg14/firebase_options.dart';
import 'package:votacionesappg14/pages/votaciones.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(home: VotacionesPage(), debugShowCheckedModeBanner: false),
  );
}
