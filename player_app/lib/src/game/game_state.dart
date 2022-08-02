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
    // // Get or create a User, which transcends individual games.
    // // Used mainly to maintain state when a user refreshes their browser
    // final firebaseUser = await FirebaseAuth.instance.signInAnonymously();
    // FirebaseFirestore.instance
    //     .collection('Users')
    //     .doc(firebaseUser.user!.uid)
    //     .snapshots()
    //     .listen((snapshot) {
    //   if (snapshot.exists) {
    //     // get user from Firestore data
    //     final data = snapshot.data() as Map<String, dynamic>;
    //     player = Player(
    //       uid: data['uid'],
    //       name: data['name'],
    //     );
    //   } else {
    //     // create new user
    //     FirebaseFirestore.instance
    //         .collection('Users')
    //         .doc(firebaseUser.user!.uid)
    //         .set(Player(
    //           uid: firebaseUser.user!.uid,
    //           name: generateRandomPlayerName(),
    //         ).toJson());
    //   }
    // });

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
