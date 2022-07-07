import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vikings_bingo/src/game/bingo_util.dart';

import '../model/player.dart';
import 'bingo_card.dart';

class GameState extends ChangeNotifier {
  final String gameId;
  final Player player;

  // these nums come from the host app. for now in development, I'm generating the numbers locally
  List<BingoCard> cards = [
    BingoCard(generateBingoCard()),
    BingoCard(generateBingoCard()),
  ];

  GameState({required this.gameId, required this.player});

  void joinGame() async {
    // Tell host that a player has joined.
    // The host will then create 3 cards and add them to Firestore
    // at location : Games/gameId/Players/playerName/Cards
    await FirebaseFirestore.instance.collection('Users').doc(player.uid).set({
      'game': gameId,
      'uid': player.uid,
      'name': player.name,
    });

    _listenForUpdatesToPlayer();
  }

  void _listenForUpdatesToPlayer() {
    // Next, listen to Games/gameId/Players/playerName (same as above)
    // When the Cards are written, populate the bingo board
    FirebaseFirestore.instance
        .collection('Games')
        .doc(gameId)
        .collection('Players')
        .doc(player.uid)
        .snapshots()
        .listen((docSnapshot) {
      final data = docSnapshot.data()!;
      player.addCards(data['cardIds']);
      player.updateStatus(PlayerStatus.playing);
    });
  }

  bool submitBingo(BingoCard card) {
    // submit numbers to Firebase
    // upateUser
    return false;
  }
}
