import 'package:flutter/material.dart';

import '../util/game_util.dart';
import 'bingo_card.dart';

class GameState extends ChangeNotifier {
  late String playerName;

  bool hasWon = false;

  final List<BingoCard> cards = [
    BingoCard(),
    BingoCard(),
  ];

  GameState() {
    playerName = generateRandomPlayerName();
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
}
