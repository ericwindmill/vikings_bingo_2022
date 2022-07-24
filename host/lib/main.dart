import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kReleaseMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  Stream<String> currentGameId = _getCurrentGameStream();
  Stream<QuerySnapshot> currentPlayers = _getGamePlayersStream("none");
  Stream<List<String>> currentNumbers = _getNumbers("none");
  Stream<QuerySnapshot> currentCards = _getCards("none");

  Map<int,int> currentScores = {};

  @override
  void initState() {
    super.initState();

    _getCurrentGameStream().listen((gameId) {
      currentPlayers = _getGamePlayersStream(gameId);
      currentNumbers = _getNumbers(gameId);
      currentCards = _getCards(gameId);
      currentPlayers.listen((snapshot) {
        if (kDebugMode) print('Got ${snapshot.docs.length} player docs');
        for (var doc in snapshot.docs) {
          var playerId = doc.id;
          var data = doc.data()! as Map;
          if (data['state'] == 'Waiting for cards') {
            _generateCardsForPlayer(gameId, playerId);
          }
        };
      });
      currentCards.listen((cardsSnapshot) {
        currentNumbers.listen((numbers) {
          Map<int,int> result = {};
          for (var card in cardsSnapshot.docs) {
            var cardId = int.parse(card.id);
            result[cardId] = _getScoreForCard(numbers, cardId);
          };
          print('Card scores: $result');
          setState(() {
            currentScores = result;
          });
        });
      });
    });
  }

  void _calculateCurrentScores() async {
    print('In _calculateCurrentScores');
    var numbers = await currentNumbers.last;
    var cards = await currentCards.last;

    print('Determining current scores for ${cards.size} cards and ${numbers.length} numbers');

    Map<int,int> result = {};
    for (var card in cards.docs) {
      var cardId = int.parse(card.id);
      result[cardId] = _getScoreForCard(numbers, cardId);
    };
    print('Card scores: $result');
    setState(() {
      currentScores = result;
    });
  }

  void _incrementCounter() {
    setState(() {
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
            StreamBuilder(
              stream: currentGameId,
              builder: (buildContext, AsyncSnapshot<String> asyncSnapshot) {
                if (asyncSnapshot.hasData) {
                  var gameId = asyncSnapshot.data!;
                  return Column(children: [ 
                    Text(
                      gameId,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const Text("Player count: "),
                    StreamBuilder(
                      stream: currentPlayers,
                      builder: (buildContext, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
                        if (asyncSnapshot.hasData) {
                          return Text(
                            '${asyncSnapshot.data!.docs.length}',
                            style: Theme.of(context).textTheme.headline4,
                          );
                        }
                        if (asyncSnapshot.hasError) {
                          return Text('${asyncSnapshot.error}');
                        }
                        return const CircularProgressIndicator();
                      }
                    ),
                    const Text("Last numbers:"),
                    StreamBuilder(
                      stream: currentNumbers,
                      builder: (buildContext, AsyncSnapshot<List<String>> asyncSnapshot) {
                        if (asyncSnapshot.hasData) {
                          var numbers = asyncSnapshot.data!;
                          return Text(
                            numbers.last,
                            style: Theme.of(context).textTheme.headline4,
                          );
                        }

                        if (asyncSnapshot.hasError) {
                          return Text('${asyncSnapshot.error}');
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                    const Text("Cards"),
                    StreamBuilder(
                      stream: currentCards,
                      builder: (buildContext, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
                        if (asyncSnapshot.hasData) {
                          var cards = asyncSnapshot.data!.docs;
                          return Text(
                            cards.map((c) => c.id).toString(),
                            style: Theme.of(context).textTheme.bodyText2,
                          );
                        }

                        if (asyncSnapshot.hasError) {
                          return Text('${asyncSnapshot.error}');
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                    const Text("Scores"),
                    Text(currentScores.toString()),
                    ElevatedButton(
                      child: const Text("Draw"),
                      onPressed: () {
                        _generateNextNumber(gameId);
                      }, 
                    )
                  ]);
                }
                if (asyncSnapshot.hasError) {
                  return Text('${asyncSnapshot.error}');
                }
                return const CircularProgressIndicator();
              }
            ),
            ElevatedButton(
              child: const Text('Start new game'),
              onPressed: () {
                // TODO: find a simpler ID generator
                var uuid = new Uuid();
                _setCurrentGameId(uuid.v1());
              }
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<void> _setCurrentGameId(String gameId) {
  var db = FirebaseFirestore.instance;
  final batch = db.batch();

  batch.update(db.collection('Globals').doc('Bootstrap'), { 'currentGame': gameId });
  batch.set(db.collection('Games').doc(gameId), { 'createdAt': Timestamp.now() });

  return batch.commit();
}
Stream<String> _getCurrentGameStream() {
  return FirebaseFirestore.instance
      .collection('Globals')
      .doc('Bootstrap')
      .snapshots().map((docSnapshot) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return data['currentGame'];
  });
}

Stream<QuerySnapshot> _getGamePlayersStream(String gameId) {
  return FirebaseFirestore.instance
      .collection('Games')
      .doc(gameId)
      .collection('Players')
      .snapshots();
}
Stream<List<String>> _getNumbers(String gameId) {
  return FirebaseFirestore.instance
      .collection('Games')
      .doc(gameId)
      .snapshots().map((docSnapshot) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return List<String>.from(data.containsKey('numbers') ? data['numbers'] : ['-none-']);
  });
}
Stream<QuerySnapshot> _getCards(String gameId) {
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
  // TODO: check that this number hasn't been drawn yet
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
  var card = _generateCardFromCardId(cardId);
  batch.set(db.doc('Games/$gameId/Players/$playerId/Cards/$cardId'), { 
    'createdAt': Timestamp.now(),
    'numbers': card,
  });
  batch.set(db.doc('Games/$gameId/Players/$playerId'), { 'state': 'Cards dealt: [$cardId]' });

  return batch.commit();
}

List<String> _generateCardFromCardId(int cardId) {
  var cardGenerator = Random(cardId);
  List<String> numbers = [];
  for (var i=0; i< 24; i++) {
    numbers.add(cardGenerator.nextInt(75).toString());
  }
  return numbers;
}


int _getScoreForCard(List<String> numbers, int cardId) {
  const lines = [[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14],[15,16,17,18,19],[20,21,22,23,24], [1,6,11,15,20],[2,7,12,16,21],[3,8,17,22],[4,9,13,18,23],[5,10,14,19,24], [1,6,18,23], [5,9,16,20]];
  var card = _generateCardFromCardId(cardId);

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