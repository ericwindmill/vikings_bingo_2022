import 'package:charts_painter/chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'dart:math';

// ignore_for_file: avoid_print

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // if (!kReleaseMode) {
  //   try {
  //     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //     await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Bingo 3000 Host'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Stream<String> gameIdStream = _getCurrentGameStream();
  String gameId = "Loading...";
  Stream<QuerySnapshot> playersStream = _getGamePlayersStream("none");
  List<QueryDocumentSnapshot> currentPlayers = [];
  Stream<List<String>> numbersStream = _getNumbersStream("none");
  List<String> currentNumbers = [];
  Stream<QuerySnapshot> cardsStream = _getCardsStream("none");
  List<QueryDocumentSnapshot> currentCards = [];

  Map<int,int> currentScores = {};

  @override
  void initState() {
    super.initState();

    gameIdStream.listen((gameId) {
      setState(() {
        this.gameId = gameId;
      });
      playersStream = _getGamePlayersStream(gameId);
      playersStream.listen((snapshot) => {
        setState(() {
          currentPlayers = snapshot.docs;
        })
      });
      numbersStream = _getNumbersStream(gameId);
      cardsStream = _getCardsStream(gameId);
      playersStream.listen((snapshot) {
        if (kDebugMode) print('Got ${snapshot.docs.length} player docs');
        for (var doc in snapshot.docs) {
          var playerId = doc.id;
          var data = doc.data()! as Map;
          if (data['status'] == 'waiting for cards') {
            _generateCardsForPlayer(gameId, playerId);
          }
          if (data['status'] == 'claiming bingo') {
            _claimBingoForPlayer(gameId, playerId, currentNumbers);
          }
        }
      });
      cardsStream.listen((cardsSnapshot) {
        setState(() {
          currentCards = cardsSnapshot.docs;
        });
        numbersStream.listen((numbers) {
          Map<int,int> result = {};
          for (var card in cardsSnapshot.docs) {
            var cardId = int.parse(card.id);
            var score = _getScoreForCard(numbers, cardId);
            result[cardId] = score;
          }
          print('Card scores: $result');
          setState(() {
            currentNumbers = numbers;
            currentScores = result;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Current game: "),
            Text(
              gameId,
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
              child: const Text('Start new game'),
              onPressed: () {
                _startNewGame();
              }
            ),
            const Text("Player count: "),
            Text(
              currentPlayers.length.toString(),
              style: Theme.of(context).textTheme.headline4
            ),
            const Text("Card count"),
            Text(
              currentCards.length.toString(),
              style: Theme.of(context).textTheme.headline3,
            ),
            const Text("Latest number(s):"),
            Row(
              children: currentNumbers.reversed.take(10).toList().asMap().entries.map((entry) {
                return (entry.key==0) 
                  ? Text(entry.value, style: Theme.of(context).textTheme.headline3)
                  : Text(" ${entry.value}", style: TextStyle(fontSize: 25.0-2.0*entry.key));
              }).toList()
            ),
            ElevatedButton(
              child: const Text("Draw"),
              onPressed: () {
                _generateNextNumber(gameId);
              }, 
            ),
            const Text("Scores"),
            //Text(currentScores.toString()),
            AnimatedChart(
              state: ChartState.bar(
                ChartData.fromList(
                  //<double>[1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BarValue<void>(e)).toList(),
                  //currentScores.values.map((score) => BarValue(1.0*score)).toList()
                  [1,2,3,4,5].map((score) => BarValue(1.0 * currentScores.values.where((e) => e == score).length)).toList(),
                  axisMax: 1.0*currentScores.length
                ),
              ),
              duration: const Duration(seconds: 1),
            ),
            ElevatedButton(
              child: const Text("Show winners"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => FullScreenDialog(gameId: gameId),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenDialog extends StatelessWidget {
  String gameId;

  FullScreenDialog({Key? key, required this.gameId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Winners'),
      ),
      body: Center(
        child: StreamBuilder(
          stream: _getWinners(gameId),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              var winners = asyncSnapshot.data! as List<QueryDocumentSnapshot>;
              print('Got ${winners.length} winners: $winners');
              return ListView(
                children: winners.map((winner) {
                  var data = winner.data()! as Map;
                  var name = data["name"];
                  var time = (data['bingoClaimTime'] as Timestamp).toDate();
                  var msg = (data['hostMessage'] ?? '-');
                  return ListTile(
                    isThreeLine: true,
                    title: Text(winner.id),
                    subtitle: Text('$name\nwon at $time\nmsg: "$msg"'),
                    trailing: IconButton(
                      icon: const Icon(Icons.sports_martial_arts_rounded),
                      onPressed: () {
                        db.doc('Games/$gameId/Players/${winner.id}').update({
                          'hostMessage': Random().nextInt(100000).toString()
                        });
                      },
                    ),
                  );
                }).toList()
              );
            }
            if (asyncSnapshot.hasError) {
              return Text('Error: ${asyncSnapshot.error}');
            }
            return const CircularProgressIndicator();
          },)
      ),
    );
  }
}

var db = FirebaseFirestore.instance;
//void _getWinners(List<QueryDocumentSnapshot> players) {
Stream<List<QueryDocumentSnapshot>> _getWinners(String gameId) {
  return db.collection('Games/$gameId/Players')
    .where('status', isEqualTo: 'wonBingo')
    .orderBy('bingoClaimTime', descending: true)
    .snapshots()
    .map((event) => event.docs);
}


Future<void> _startNewGame() {
  var db = FirebaseFirestore.instance;
  final batch = db.batch();

  var gameId = FirebaseFirestore.instance.collection("Games").doc().id;

  batch.update(db.collection('Globals').doc('Bootstrap'), { 'currentGame': gameId });
  batch.set(db.collection('Games').doc(gameId), { 'createdAt': Timestamp.now() });

  return batch.commit();
}
Stream<String> _getCurrentGameStream() {
  return FirebaseFirestore.instance
      .doc('Globals/Bootstrap')
      .snapshots().map((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['currentGame'];
      }
      else {
        return '-none-';
      }
  });
}

Stream<QuerySnapshot> _getGamePlayersStream(String gameId) {
  return FirebaseFirestore.instance
      .collection('Games')
      .doc(gameId)
      .collection('Players')
      .snapshots();
}
Stream<List<String>> _getNumbersStream(String gameId) {
  return FirebaseFirestore.instance
      .collection('Games')
      .doc(gameId)
      .snapshots().map((docSnapshot) {
        // TODO: Unhandled Exception: type 'Null' is not a subtype of type 'Map<String, dynamic>' in type cast
      if (docSnapshot.exists && docSnapshot.data() != null && docSnapshot.data()!.containsKey('numbers')) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return List<String>.from(data['numbers']);
      }
      else {
        return  ['-none-'];
      }
  });
}
Stream<QuerySnapshot> _getCardsStream(String gameId) {
  var path = '/Games/$gameId';
  return FirebaseFirestore.instance
    .collectionGroup("Cards")
    .orderBy(FieldPath.documentId)
    .startAt([path])
    .endAt(['$path\uf8ff'])
    .snapshots();
}

Future<void> _generateNextNumber(String gameId) {
  var number = random.nextInt(75).toString();
  // TODO: check that this number hasn't been drawn yet, otherwise this is a noop - which looks weird
  return FirebaseFirestore.instance
      .collection('Games')
      .doc(gameId)
      .update({ 'numbers': FieldValue.arrayUnion([number]) });
}

Random random = Random(); // main randomizer

Future<void> _generateCardsForPlayer(String gameId, String playerId) {
  var db = FirebaseFirestore.instance;
  final batch = db.batch();

  var cardId = random.nextInt(1<<32);
  var card = _getNumbersForCardId(cardId);
  batch.set(db.doc('Games/$gameId/Players/$playerId/Cards/$cardId'), { 
    'createdAt': Timestamp.now(),
    'numbers': card,
  });
  batch.update(db.doc('Games/$gameId/Players/$playerId'), { 'status': 'cards dealt' });

  return batch.commit();
}

Future<bool> _claimBingoForPlayer(String gameId, String playerId, List<String> numbers) async {
  var hasBingo = false;
  // get cards for player
  var snapshot = await FirebaseFirestore.instance.collection('Games/$gameId/Players/$playerId/Cards/').get();
  var cardIds = snapshot.docs.map((doc) => int.parse(doc.id));
  for (var cardId in cardIds) {
    // if this card has a score of 5, the claim is correct
    if (_getScoreForCard(numbers, cardId) >= 5) {
      hasBingo = true;
    }
  }

  await FirebaseFirestore.instance
    .doc('Games/$gameId/Players/$playerId')
    .update({ 'status': hasBingo ? 'wonBingo' : 'false bingo' });

  return hasBingo;
}

List<String> _getNumbersForCardId(int cardId) {
  var cardGenerator = Random(cardId);
  List<String> numbers = [];
  for (var i=0; i< 24; i++) {
    numbers.add(cardGenerator.nextInt(75).toString());
  }
  return numbers;
}


int _getScoreForCard(List<String> numbers, int cardId) {
  const lines = [[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14],[15,16,17,18,19],[20,21,22,23,24], [1,6,11,15,20],[2,7,12,16,21],[3,8,17,22],[4,9,13,18,23],[5,10,14,19,24], [1,6,18,23], [5,9,16,20]];
  var card = _getNumbersForCardId(cardId);

  var maxLength = 0;
  for (var line in lines) {
    var length = lines.length == 4 ? 1 : 0;
    for (var index in line) {
      if (numbers.contains(card[index-1])) {
        length++;
      }
    }
    if (length > maxLength) {
      maxLength = length;
    }
  }
  return maxLength;
}

MapEntry<String,String> _getPlayerForCard(List<QueryDocumentSnapshot> cards, List<QueryDocumentSnapshot> players, int cardId) {
  var cardDoc = cards.firstWhere((doc) => doc.id == cardId.toString());
  var uid = cardDoc.reference.parent.parent!.id;
  var playerDoc = players.firstWhere((doc) => doc.id == uid);
  var data = playerDoc.data() as Map;

  return MapEntry(uid, data["name"]);
}