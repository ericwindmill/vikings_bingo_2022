import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/bingo_card.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';

class FirestoreService {
  static Future<void> joinLobby(
      {required String gameId, required Player player}) async {
    await FirebaseFirestore.instance
        .collection('Games/$gameId/Players')
        .doc(player.uid)
        .set({
      'status': PlayerStatus.newPlayer.value,
      'name': player.name,
    });
  }

  static void joinGame({required String gameId, required Player player}) async {
    await FirebaseFirestore.instance
        .collection('Games/$gameId/Players')
        .doc(player.uid)
        .update({
      'status': PlayerStatus.waitingForCards.value,
      'name': player.name,
    });
  }

  static Future<void> updatePlayerStatus(
      PlayerStatus newStatus, Player player, String gameId) async {
    player.status = newStatus;
    await FirebaseFirestore.instance
        .collection('Games/$gameId/Players')
        .doc(player.uid)
        .set({
      'status': player.status!.value,
      'name': player.name,
      if (player.status == PlayerStatus.claimingBingo)
        'bingoClaimTime': FieldValue.serverTimestamp(),
    });
  }

  static void submitBingo(Player player, String gameId) {
    updatePlayerStatus(PlayerStatus.claimingBingo, player, gameId);
  }

  static Stream<String> gameIdStream() {
    return FirebaseFirestore.instance
        .doc('Globals/Bootstrap')
        .snapshots()
        .map((DocumentSnapshot? docSnapshot) {
      if (docSnapshot == null) return 'none';
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['currentGame'];
      }
      return 'none';
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

  static Stream<PlayerStatus?> getPlayerStatusUpdates(String gameId) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('Games/$gameId/Players')
        .doc(uid)
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final st = data['status'];
        return statusFromString[st];
      } else {
        return null;
      }
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

  static Future<bool> playerHasCards(
    String gameId,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final cardsCollection = await FirebaseFirestore.instance
        .collection('Games/$gameId/Players/$uid/Cards')
        .get();
    return cardsCollection.docs.isNotEmpty;
  }
}
