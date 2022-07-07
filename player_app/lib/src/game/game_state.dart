import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vikings_bingo/src/game/bingo_util.dart';

import '../model/player.dart';
import 'bingo_card.dart';

class GameState extends ChangeNotifier {
  final String gameId;
  final Player player;
  bool loading = false;

  // these nums come from the host app. for now in development, I'm generating the numbers locally
  final List<BingoCard> cards = [
    BingoCard(generateBingoCard()),
    BingoCard(generateBingoCard()),
  ];

  GameState({required this.gameId, required this.player});

  void toggleLoading() {
    loading = !loading;
    notifyListeners();
  }

  void joinGame() async {
    // Tell host that a player has joined.
    // The host will then create 3 cards and add them to Firestore
    // at location : Games/gameId/Players/playerName/Cards
    await FirebaseFirestore.instance.collection('Users').doc(player.uid).set({
      'game': gameId,
      'uid': player.uid,
      'name': player.name,
    });

    toggleLoading();
  }

  void listenForCardsFromHost() {
    // Next, listen to Games/gameId/Players/playerName (same as above)
    // When the Cards are written, populate the bingo board
    FirebaseFirestore.instance
        .collection('Games')
        .doc(gameId)
        .collection('Players')
        .doc(player!.name)
        .snapshots()
        .listen((docSnapshot) {
      final data = docSnapshot.data()!;
      player!.addCards(data['cardIds']);
    });
  }

  bool submitBingo(BingoCard card) {
    // Submit values to firebase
    // get response on win or not
    // toggle has won to update UI
    return false;
  }
}
