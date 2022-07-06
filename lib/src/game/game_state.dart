import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vikings_bingo/src/util/bingo_util.dart';

import '../util/game_util.dart';
import 'bingo_card.dart';

enum PlayerStatus {
  waitingForCards,
  playing,
  claimingBingo,
}

class GameState extends ChangeNotifier {
  late final String gameId;
  late String playerName;
  PlayerStatus playerStatus = PlayerStatus.waitingForCards;

  // these nums come from the host app. for now in development, I'm generating the numbers locally
  final List<BingoCard> cards = [
    BingoCard(generateBingoCard()),
    BingoCard(generateBingoCard()),
  ];

  GameState() {
    playerName = generateRandomPlayerName();
    _initFirebaseListener();
  }

  regenerateName() {
    playerName = generateRandomPlayerName();
    notifyListeners();
  }

  bool submitBingo(BingoCard card) {
    // Submit values to firebase
    // get response on win or not
    // toggle has won to update UI
    return false;
  }

  void _initFirebaseListener() {
    FirebaseFirestore.instance
        .collection('Globals')
        .doc('Bootstrap')
        .snapshots()
        .listen((DocumentSnapshot docEvent) {
      final data = docEvent.data() as Map<String, dynamic>;
      final currentGameId = data['currentGame'];
      gameId = currentGameId;
      // here we can do logic to change the app if the gameId changes.
    });

    // todo: Listen to Games/id/Players/name/Cards, and then fetch cards with ID on update
  }
}
