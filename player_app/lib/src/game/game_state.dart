import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared/bingo_card.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';

class GameState extends ChangeNotifier {
  String? gameId;
  final Player player;
  final List<BingoCard> cards = [];

  GameState({required this.player}) {
    // Subscribe to Globals/Bootstrap happen
    FirebaseFirestore.instance
        .collection('Globals')
        .doc('Bootstrap')
        .snapshots()
        .listen((event) {
      final game = event.data()!['currentGame'] as String;
      gameId = game;
      notifyListeners();
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

    // Attempt to get cards, if any exist.
    // This is helpful for Web, where people can
    // refresh their browser and it wipes all state
    _getCardsForPlayer();

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
      final data = (docSnapshot.data() as Map);
      final status = data['status'];
      var playerStatus = statusFromString[status];
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
        case null:
          print("oopsies, that ain't a status");
      }
    });
  }

  void _getCardsForPlayer() {
    FirebaseFirestore.instance
        .collection('Games/$gameId/Players/${player.uid}/Cards')
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isEmpty) return;
      final bingoCards = snapshot.docs.map((DocumentSnapshot doc) {
        final data = doc.data();
        final bingoValues = (data as Map<String, List<String>>)['cards'];
        return BingoCard.fromListOfValues(bingoValues as List<String>);
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
