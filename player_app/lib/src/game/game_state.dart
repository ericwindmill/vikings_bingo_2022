import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared/bingo_card.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';

import '../util/game_util.dart';

class GameState extends ChangeNotifier {
  String? gameId;
  final List<BingoCard> cards = [];

  late Player _player;
  final StreamController<Player> _playerStreamController =
      StreamController<Player>();
  Stream<Player> get player => _playerStreamController.stream;

  GameState() {
    _init();
  }

  void _init() async {
    // Get or create a User, which transcends individual games.
    // Used mainly to maintain state when a user refreshes their browser
    final firebaseUser = await FirebaseAuth.instance.signInAnonymously();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(firebaseUser.user!.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        // get user from Firestore data
        final data = snapshot.data() as Map<String, dynamic>;
        _player = Player(
          uid: data['uid'],
          name: data['name'],
        );
        _playerStreamController.add(_player);
      } else {
        // create new user
        FirebaseFirestore.instance
            .collection('Users')
            .doc(firebaseUser.user!.uid)
            .set(Player(
              uid: firebaseUser.user!.uid,
              name: generateRandomPlayerName(),
            ).toJson());
      }
    });

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

  void _checkForExistingGameState() {}

  void joinGame() async {
    // Tell host that a player has joined.
    // The host will then create a few cards and add them to Firestore
    // at location : Games/gameId/Players/playerName/Cards
    await FirebaseFirestore.instance
        .collection('Games/$gameId/Players')
        .doc(_player.uid)
        .set({
      'status': _player.status.value,
      'name': _player.name,
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
        .doc(_player.uid)
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
        case PlayerStatus.falseBingo:
          // TODO: Handle this case.
          // https://www.google.com/search?q=did+you+really+though+meme
          break;
        case null:
          print("oopsies, that ain't a status");
      }
    });
  }

  void _getCardsForPlayer() {
    FirebaseFirestore.instance
        .collection('Games/$gameId/Players/${_player.uid}/Cards')
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
    if (newStatus != _player.status) {
      _player.status = newStatus;
      FirebaseFirestore.instance
          .collection('Games/$gameId/Players')
          .doc(_player.uid)
          .update({
        'status': _player.status.value,
      });
      _playerStreamController.add(_player);
    }
  }
}
