import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/player.dart';
import 'package:vikings_bingo/src/app.dart';
import 'package:vikings_bingo/src/style/palette.dart';
import 'package:vikings_bingo/src/util/game_util.dart';

import 'firebase_options.dart';
import 'src/game/game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // if (!kReleaseMode) {
  //   try {
  //     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //     await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  Player player = await _bootstrapPlayer();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => Palette()),
        ChangeNotifierProvider(
          create: (context) {
            return GameState(player: player);
          },
          lazy: false,
        ),
      ],
      child: const BingoPlayerApp(),
    ),
  );
}

Future<Player> _bootstrapPlayer() async {
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
  } else {
    player = Player.fromJson(firestoreUser);
  }

  return player;
}
