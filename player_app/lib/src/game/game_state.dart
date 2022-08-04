import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared/bingo_card.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';

class GameState extends ChangeNotifier {
  String? gameId;
  final List<BingoCard> cards = [];
  Player player;

  GameState({required this.player}) {
    _init();
  }

  void _init() async {
    // Subscribe to Globals/Bootstrap to determine current game
    FirebaseFirestore.instance
        .collection('Globals')
        .doc('Bootstrap')
        .snapshots()
        .listen((event) {
      final game = event.data()!['currentGame'] as String;
      gameId = game;
      notifyListeners();
    });

    _checkForExistingGameState();
  }

  // if a user refreshes the browser from the '/play' route, we need to re-fetch
  // their card collection
  void _checkForExistingGameState() {
    final ref =
        FirebaseFirestore.instance.doc('Games/$gameId/Players/${player.uid}');
    ref.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        final status = docSnapshot.data()!['status'];
        if (statusFromString.containsKey(status) &&
            statusFromString[status] != PlayerStatus.waitingForCards) {
          _getCardsForPlayer();
        }
      }
    });
  }

  void joinGame() async {
    // Tell host that a player has joined.
    // The host will then create a few cards and add them to Firestore
    // at location : Games/gameId/Players/playerName/Cards
    await FirebaseFirestore.instance
        .collection('Games/$gameId/Players')
        .doc(player.uid)
        .set({
      'status': player.status.value,
      'name': player.name,
    });

    _listenForUpdatesToPlayer();
  }

  void submitBingo(BingoCard card) {
    _updatePlayerStatus(PlayerStatus.claimingBingo);
  }

  void _listenForUpdatesToPlayer() {
    FirebaseFirestore.instance
        .collection('Games/$gameId/Players')
        .doc(player.uid)
        .snapshots()
        .listen((docSnapshot) {
      final data = (docSnapshot.data());
      final status = data!['status'];
      var playerStatus = statusFromString[status];
      player.status = playerStatus!;
      switch (playerStatus) {
        case PlayerStatus.waitingForCards:
          break;
        case PlayerStatus.cardsDealt:
          _getCardsForPlayer();
          break;
        case PlayerStatus.playing:
          // TODO: Handle this case.
          break;
        case PlayerStatus.claimingBingo:
          // TODO: Handle this case.
          break;
        case PlayerStatus.wonBingo:
          // TODO: Handle this case.
          break;
        case PlayerStatus.falseBingo:
          notifyListeners();
          break;
      }
    });
  }

  void _getCardsForPlayer() {
    FirebaseFirestore.instance
        .collection('Games/$gameId/Players/${player.uid}/Cards')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isEmpty) return;
      final bingoCards = snapshot.docs.map((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        final bingoValues = List<String>.from(data['numbers'] as List<dynamic>);
        return BingoCard.fromListOfValues(bingoValues);
      }).toList();

      cards.addAll(bingoCards);
      notifyListeners();
    });
  }

  void _updatePlayerStatus(PlayerStatus newStatus) {
    if (newStatus != player.status) {
      player.status = newStatus;
      FirebaseFirestore.instance
          .collection('Games/$gameId/Players')
          .doc(player.uid)
          .update({
        'status': player.status.value,
      });
    }
  }
}
