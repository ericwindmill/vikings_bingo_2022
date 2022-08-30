import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared/player.dart';

import 'firebase_options.dart';
import 'src/app_refactor.dart';
import 'src/util/game_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.signInAnonymously();

  runApp(AppShell());
}

Future<Player> bootstrapPlayer() async {
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) return;

    if (user.displayName == null) {
      await user.updateDisplayName(generateRandomPlayerName());
    }
  });

  final cred = await FirebaseAuth.instance.signInAnonymously();
  return Player(uid: cred.user!.uid, name: cred.user!.displayName!);
}
