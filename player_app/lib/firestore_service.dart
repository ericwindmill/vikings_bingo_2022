import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/bingo_card.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';

class FirestoreService {
  static Future<void> updatePlayerStatus(
      PlayerStatus newStatus, Player player, String gameId) async {
    print(
        'changing status: from ${player.status ?? 'no player'} to: $newStatus');
    try {
      player.status = newStatus;
      await FirebaseFirestore.instance
          .collection('Games/$gameId/Players')
          .doc(player.uid)
          .set({
        'status': player.status!.value,
        'name': player.name,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      print('msg: ${e.message}, code: ${e.code}');
    }
  }

  static void submitBingo(Player player, String gameId) async {
    try {
      player.status = PlayerStatus.claimingBingo;
      await FirebaseFirestore.instance
          .collection('Games/$gameId/Players')
          .doc(player.uid)
          .set({
        'status': player.status!.value,
        'bingoClaimTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      print('msg: ${e.message}, code: ${e.code}');
    }
  }

  // static Future<void> updateStatus(
  //     PlayerStatus newStatus, Player player, String gameId) async {
  //   player.status = newStatus;
  //
  //   Map<String, dynamic> updates = {};
  //   final doc = FirebaseFirestore.instance
  //       .collection('Games/$gameId/Players')
  //       .doc(player.uid);
  //
  //   switch (newStatus) {
  //     case PlayerStatus.newPlayer:
  //       updates['name'] = player.name;
  //       updates['status'] = newStatus;
  //       doc.set(updates, SetOptions(merge: true));
  //       break;
  //     case PlayerStatus.inLobby:
  //       updates['name'] = player.name;
  //       updates['status'] = newStatus;
  //       doc.set(updates, SetOptions(merge: true));
  //       break;
  //     case PlayerStatus.waitingForCards:
  //       updates['name'] = player.name;
  //       updates['status'] = newStatus;
  //       doc.set(updates, SetOptions(merge: true));
  //       break;
  //     case PlayerStatus.cardsDealt:
  //       // TODO: Handle this case.
  //       break;
  //     case PlayerStatus.playing:
  //       // TODO: Handle this case.
  //       break;
  //     case PlayerStatus.claimingBingo:
  //       // TODO: Handle this case.
  //       break;
  //     case PlayerStatus.wonBingo:
  //       // TODO: Handle this case.
  //       break;
  //     case PlayerStatus.falseBingo:
  //       // TODO: Handle this case.
  //       break;
  //   }
  // }

  static Stream<String?> gameIdStream() {
    return FirebaseFirestore.instance
        .doc('Globals/Bootstrap')
        .snapshots()
        .map((DocumentSnapshot? docSnapshot) {
      if (docSnapshot != null &&
          docSnapshot.exists &&
          docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['currentGame'];
      }
    });
  }

  static Stream<List<BingoCard>> getCardsForPlayerStream(
      String gameId, Player player) {
    return FirebaseFirestore.instance
        .collection('Games/$gameId/Players/${player.uid}/Cards')
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isEmpty) return <BingoCard>[];
      return querySnapshot.docs.map((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        final bingoValues = List<String>.from(data['numbers'] as List<dynamic>);
        return BingoCard.fromListOfValues(bingoValues);
      }).toList();
    });
  }

  static Stream<Player> getPlayerStream(String gameId) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('Games/$gameId/Players')
        .doc(uid)
        .snapshots()
        .map((DocumentSnapshot docSnapshot) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return Player.fromJson(data, uid: uid);
    });
  }
}
