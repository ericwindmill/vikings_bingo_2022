import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared/player.dart';
import 'package:vikings_bingo/src/app.dart';

import 'firebase_options.dart';
import 'src/util/game_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final player = await bootstrapPlayer();

  runApp(
    BingoPlayerApp(player: player),
  );
}

Future<Player> bootstrapPlayer() async {
  final cred = await FirebaseAuth.instance.signInAnonymously();
  Player player;
  final firestoreUser = await FirebaseFirestore.instance
      .collection('Users')
      .doc(cred.user!.uid)
      .get()
      .then((value) {
    return value.data();
  });

// The player doesn't exist (i.e. they've never loaded this app),
// create the player
  if (firestoreUser == null) {
    player = Player(
      uid: cred.user!.uid,
      name: generateRandomPlayerName(),
    );
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(cred.user!.uid)
        .set(player.toJson());
  } else {
    player = Player.fromJson(firestoreUser);
  }

  return player;
}
